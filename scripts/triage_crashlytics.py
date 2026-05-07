import subprocess
import json
import os
import time

PROJECT_DIR = '/Users/remelehane/Projects/threed_print_cost_calculator'
MCP_SCRIPT = f'{PROJECT_DIR}/scripts/run_firebase_mcp.sh'

def call_mcp(proc, method, params, request_id):
    request = json.dumps({
        "jsonrpc": "2.0",
        "id": request_id,
        "method": method,
        "params": params
    }) + '\n'
    proc.stdin.write(request)
    proc.stdin.flush()
    
    # We need to read until we get a response for this ID
    while True:
        line = proc.stdout.readline()
        if not line:
            break
        try:
            resp = json.loads(line)
            if resp.get("id") == request_id:
                return resp
        except json.JSONDecodeError:
            continue
    return None

def main():
    os.chdir(PROJECT_DIR)
    proc = subprocess.Popen(
        [MCP_SCRIPT],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        cwd=PROJECT_DIR
    )

    # Initialize
    init_request = json.dumps({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hermes-cron", "version": "1.0"}
        }
    }) + '\n'
    proc.stdin.write(init_request)
    proc.stdin.flush()
    time.sleep(2)
    # Consume the initialize response
    proc.stdout.readline()

    app_ids = {
        "android": "1:476308766683:android:7fc07cf44f4526bc0c31fe",
        "ios": "1:476308766683:ios:df64edd07e4671b80c31fe"
    }

    results = {}
    for platform, app_id in app_ids.items():
        print(f"Fetching reports for {platform}...")
        resp = call_mcp(
            proc, 
            "tools/call", 
            {"name": "crashlytics_get_report", "arguments": {"report": "topIssues", "appId": app_id}}, 
            2 if platform == "android" else 3
        )
        results[platform] = resp

    print(json.dumps(results, indent=2))
    proc.terminate()

if __name__ == "__main__":
    main()
