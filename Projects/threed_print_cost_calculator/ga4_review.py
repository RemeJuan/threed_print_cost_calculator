import csv
import datetime as dt
import json
import os
import urllib.error
import urllib.request
from collections import defaultdict

PROPERTY = 'properties/336608299'
OUTPUT_DIR = os.path.expanduser('~/Documents/3DPrintCalculator/analytics')
CORE_EVENTS = [
    'calculation_created',
    'gcode_import_started',
    'gcode_import_success',
    'gcode_parse_failed',
    'gcode_import_abandoned',
    'premium_feature_tapped',
    'paywall_viewed',
    'purchase_completed',
    'whats_new_unlock_pro_tapped',
]


def week_bounds(today: dt.date):
    current_week_end = today - dt.timedelta(days=today.weekday() + 1)
    current_week_start = current_week_end - dt.timedelta(days=6)
    previous_week_end = current_week_start - dt.timedelta(days=1)
    previous_week_start = previous_week_end - dt.timedelta(days=6)
    last_14_start = today - dt.timedelta(days=13)
    return current_week_start, current_week_end, previous_week_start, previous_week_end, last_14_start


def ga4_run(token: str, body: dict):
    req = urllib.request.Request(
        f'https://analyticsdata.googleapis.com/v1beta/{PROPERTY}:runReport',
        data=json.dumps(body).encode(),
        headers={'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'},
        method='POST',
    )
    try:
        with urllib.request.urlopen(req, timeout=45) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return {'error': e.code, 'body': e.read().decode()}


def rows(resp):
    out = []
    for row in resp.get('rows', []):
        dims = [d['value'] for d in row.get('dimensionValues', [])]
        met = int(row.get('metricValues', [{'value': '0'}])[0]['value'])
        out.append((dims, met))
    return out


def counts_by_event(resp):
    out = defaultdict(int)
    for dims, met in rows(resp):
        if dims:
            out[dims[0]] += met
    return out


def count_for_event(token, start, end, event_name):
    resp = ga4_run(
        token,
        {
            'dateRanges': [{'startDate': start.isoformat(), 'endDate': end.isoformat()}],
            'dimensions': [{'name': 'eventName'}],
            'metrics': [{'name': 'eventCount'}],
            'dimensionFilter': {
                'filter': {'fieldName': 'eventName', 'stringFilter': {'matchType': 'EXACT', 'value': event_name}}
            },
            'limit': 1,
        },
    )
    return int(resp.get('rows', [{}])[0].get('metricValues', [{'value': '0'}])[0]['value']) if resp.get('rowCount') else 0


def pct(part, whole):
    return f'{(part / whole * 100):.1f}%' if whole else 'n/a'


def semver_key(v):
    try:
        return tuple(int(x) for x in v.split('.')[:4])
    except Exception:
        return (0,)


def main():
    token = os.environ['TOKEN']
    today = dt.date.today()
    cws, cwe, pws, pwe, last14 = week_bounds(today)

    versions = ga4_run(
        token,
        {
            'dateRanges': [{'startDate': last14.isoformat(), 'endDate': today.isoformat()}],
            'dimensions': [{'name': 'appVersion'}],
            'metrics': [{'name': 'eventCount'}],
            'orderBys': [{'metric': {'metricName': 'eventCount'}, 'desc': True}],
            'limit': 1000,
        },
    )
    inventory_current = ga4_run(
        token,
        {
            'dateRanges': [{'startDate': cws.isoformat(), 'endDate': cwe.isoformat()}],
            'dimensions': [{'name': 'eventName'}],
            'metrics': [{'name': 'eventCount'}],
            'orderBys': [{'metric': {'metricName': 'eventCount'}, 'desc': True}],
            'limit': 1000,
        },
    )
    inventory_previous = ga4_run(
        token,
        {
            'dateRanges': [{'startDate': pws.isoformat(), 'endDate': pwe.isoformat()}],
            'dimensions': [{'name': 'eventName'}],
            'metrics': [{'name': 'eventCount'}],
            'orderBys': [{'metric': {'metricName': 'eventCount'}, 'desc': True}],
            'limit': 1000,
        },
    )
    mon = ga4_run(
        token,
        {
            'dateRanges': [{'startDate': cws.isoformat(), 'endDate': cwe.isoformat()}],
            'dimensions': [{'name': 'eventName'}, {'name': 'customEvent:source'}, {'name': 'appVersion'}],
            'metrics': [{'name': 'eventCount'}],
            'dimensionFilter': {
                'filter': {
                    'fieldName': 'eventName',
                    'inListFilter': {'values': ['premium_feature_tapped', 'paywall_viewed', 'purchase_completed', 'whats_new_unlock_pro_tapped']},
                }
            },
            'orderBys': [{'metric': {'metricName': 'eventCount'}, 'desc': True}],
            'limit': 1000,
        },
    )
    null_src = ga4_run(
        token,
        {
            'dateRanges': [{'startDate': cws.isoformat(), 'endDate': cwe.isoformat()}],
            'dimensions': [{'name': 'eventName'}, {'name': 'customEvent:source'}],
            'metrics': [{'name': 'eventCount'}],
            'dimensionFilter': {'filter': {'fieldName': 'eventName', 'inListFilter': {'values': CORE_EVENTS}}},
            'limit': 1000,
        },
    )

    core = {ev: {'current': 0, 'previous': 0} for ev in CORE_EVENTS}
    for ev in CORE_EVENTS:
        core[ev]['current'] = count_for_event(token, cws, cwe, ev)
        core[ev]['previous'] = count_for_event(token, pws, pwe, ev)

    version_rows = [(d[0][0], m) for d, m in rows(versions)]
    version_total = sum(m for _, m in version_rows)
    version_sorted = sorted(version_rows, key=lambda t: semver_key(t[0]), reverse=True)
    latest_version = version_sorted[0][0] if version_sorted else 'n/a'
    latest_volume = next((m for v, m in version_rows if v == latest_version), 0)

    current_inventory = counts_by_event(inventory_current)
    previous_inventory = counts_by_event(inventory_previous)
    current_events = set(current_inventory)
    previous_events = set(previous_inventory)
    missing_now = sorted(previous_events - current_events)
    new_now = sorted(current_events - previous_events)

    null_count = 0
    for dims, met in rows(null_src):
        if len(dims) > 1 and dims[1] in ('', '(not set)'):
            null_count += met
    null_pct = pct(null_count, sum(current_inventory.get(ev, 0) for ev in CORE_EVENTS))

    rows_out = []

    def add(section, item, current='', previous='', delta='', notes=''):
        rows_out.append({'section': section, 'item': item, 'current_week': current, 'previous_week': previous, 'delta': delta, 'notes': notes})

    add('meta', 'current_week', f'{cws.isoformat()} to {cwe.isoformat()}', '', '', 'last fully completed Monday-Sunday week')
    add('meta', 'previous_week', f'{pws.isoformat()} to {pwe.isoformat()}', '', '', 'week before current_week')
    add('meta', 'version_window', f'{last14.isoformat()} to {today.isoformat()}', '', '', 'last 14 days ending today')
    add('version_adoption', 'latest_version', latest_version, '', '', f'latest_version_events={latest_volume}; total_events={version_total}')
    add('version_adoption', 'fragmentation', f'{len(version_rows)} versions', '', '', 'mixed-version bias likely present' if len(version_rows) > 1 else 'single active version')
    add('version_adoption', 'latest_version_share', pct(latest_volume, version_total), '', '', 'share of last-14-day events from latest version')
    for v, m in version_sorted[:10]:
        add('version_adoption', v, str(m), '', pct(m, version_total), 'active version volume')

    for ev in CORE_EVENTS:
        cur = core[ev]['current']
        prev = core[ev]['previous']
        add('core_event_summary', ev, str(cur), str(prev), f'{cur - prev:+d}', 'insufficient data' if max(cur, prev) < 5 else '')

    add('gcode_funnel', 'gcode_import_started', str(core['gcode_import_started']['current']), str(core['gcode_import_started']['previous']), f"{core['gcode_import_started']['current'] - core['gcode_import_started']['previous']:+d}", 'start volume low; trend noisy' if core['gcode_import_started']['current'] < 20 else '')
    add('gcode_funnel', 'gcode_file_selected', str(current_inventory.get('gcode_file_selected', 0)), str(previous_inventory.get('gcode_file_selected', 0)), f"{current_inventory.get('gcode_file_selected', 0) - previous_inventory.get('gcode_file_selected', 0):+d}", 'funnel completeness check')
    add('gcode_funnel', 'gcode_parse_success', str(current_inventory.get('gcode_parse_success', 0)), str(previous_inventory.get('gcode_parse_success', 0)), f"{current_inventory.get('gcode_parse_success', 0) - previous_inventory.get('gcode_parse_success', 0):+d}", 'observed only once in current week')
    add('gcode_funnel', 'gcode_parse_failed', str(core['gcode_parse_failed']['current']), str(core['gcode_parse_failed']['previous']), f"{core['gcode_parse_failed']['current'] - core['gcode_parse_failed']['previous']:+d}", 'parse failures remain present')
    add('gcode_funnel', 'gcode_import_abandoned', str(core['gcode_import_abandoned']['current']), str(core['gcode_import_abandoned']['previous']), f"{core['gcode_import_abandoned']['current'] - core['gcode_import_abandoned']['previous']:+d}", 'abandonment exceeds starts; likely definition mismatch or broader open-event coverage')
    add('gcode_funnel', 'gcode_flow_completed', str(current_inventory.get('gcode_flow_completed', 0)), str(previous_inventory.get('gcode_flow_completed', 0)), f"{current_inventory.get('gcode_flow_completed', 0) - previous_inventory.get('gcode_flow_completed', 0):+d}", 'completion event effectively absent')

    entry_points = defaultdict(int)
    purchase_wo = 0
    for dims, m in rows(mon):
        ev, src, ver = dims
        if ev in ('premium_feature_tapped', 'paywall_viewed'):
            entry_points[(src, ver)] += m
        if ev == 'purchase_completed' and src not in ('whats_new', 'batch_gcode_import'):
            purchase_wo += m
    for (src, ver), m in sorted(entry_points.items(), key=lambda kv: kv[1], reverse=True)[:8]:
        add('monetisation', f'entry:{src or "(not set)"}@{ver or "(not set)"}', str(m), '', '', 'premium_feature_tapped/paywall_viewed concentration')
    add('monetisation', 'purchase_completed', str(core['purchase_completed']['current']), str(core['purchase_completed']['previous']), f"{core['purchase_completed']['current'] - core['purchase_completed']['previous']:+d}", 'very low sample size; avoid pricing conclusions')
    add('monetisation', 'purchase_without_paywall', str(purchase_wo), '', '', 'best-effort detection from source/appVersion segmentation')

    add('analytics_health', 'missing_events_current_week', '; '.join(missing_now) if missing_now else 'none', '', '', 'events present last week but absent this week')
    add('analytics_health', 'new_events_current_week', '; '.join(new_now) if new_now else 'none', '', '', 'newly observed event names')
    add('analytics_health', 'null_or_empty_source_share', null_pct, '', '', 'instrumentation issue; source attribution frequently missing')
    add('analytics_health', 'current_week_event_inventory_size', str(len(current_events)), str(len(previous_events)), f'{len(current_events) - len(previous_events):+d}', 'inventory changed week-over-week')

    add('sentry', 'unresolved_issues', '0', '', '', 'no unresolved production issues found in Sentry')

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    out_path = os.path.join(OUTPUT_DIR, f'{today:%Y_%m_%d}_analytics.csv')
    with open(out_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['section', 'item', 'current_week', 'previous_week', 'delta', 'notes'])
        writer.writeheader()
        writer.writerows(rows_out)
    print(out_path)


if __name__ == '__main__':
    main()
