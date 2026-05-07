import subprocess
import json
import os
import time
import sys

PROJECT_DIR = '/Users/remelehane/Projects/threed_print_cost_calculator'
MCP_SCRIPT = f'{PROJECT_DIR}/scripts/run_firebase_mcp.sh'

def main():
    os.chdir(PROJECT_DIR)
    
    proc = subprocess.Popen(
        [MCP_SCRIPT],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        cwd=PROJECT_DIR,
        bufsize=1
    )

    def send_and_wait(method, params=None, req_id=1):
        req = json.dumps({
            "jsonrpc": "2.0",
            "id": req_id,
            "method": method,
            "params": params or {}
        }) + '\n'
        proc.stdin.write(req)
        proc.stdin.flush()
        
        # Read until we get a response with the same ID
        while True:
            line = proc.stdout.readline()
            if not line:
                break
            try:
                resp = json.loads(line)
                if resp.get("id") == req_id:
                    return resp
            except json.JSONDecodeError:
                continue
        return None

    # 1. Initialize
    send_and_wait("initialize", {
        "protocolVersion": "2024-11-05",
        "capabilities": {},
        "clientInfo": {"name": "hermes-cron", "version": "1.0.0"}
    }, 1)

    app_ids = {
        "android": "1:476308766683:android:7fc07cf44f4526bc0c31fe",
        "ios": "1:476308766683:ios:df64edd07e4671b80c31fe"
    }

    all_issues = {"android": [], "ios": []}

    for platform, app_id in app_ids.items():
        resp = send_and_wait("tools/call", {
            "name": "crashlytics_get_report",
            "arguments": {
                "report": "topIssues",
                "appId": app_id
            }
        }, 2)
        
        if resp and "result" in resp:
            # The result might be a list of issues or a wrapper
            res = resp["result"]
            if isinstance(res, list):
                all_issues[platform] = res
            elif isinstance(res, dict) and "issues" in res:
                all_issues[platform] = res["issues"]
            else:
                all_issues[platform] = res

    print(json.dumps(all_issues))
    proc.stdin.close()
    proc.terminate()

if __name__ == "__main__":
    main()
