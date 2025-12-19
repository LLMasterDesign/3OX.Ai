#!/usr/bin/env python3
"""
RUN.PY :: .3OX Runtime for API Calls
Minimal test implementation
"""

import xxhash
import json
import yaml
import toml
from datetime import datetime
from pathlib import Path

# ============================================================================
# Core Functions
# ============================================================================

def validate_file(filepath):
    """Check if file exists and get hash"""
    p = Path(filepath)
    if not p.exists():
        return {"valid": False, "error": "File not found"}
    
    with open(p, 'rb') as f:
        file_hash = xxhash.xxh3_64_hexdigest(f.read())
    
    return {
        "valid": True,
        "path": str(p),
        "hash": file_hash[:16],
        "size": p.stat().st_size
    }

def load_tools():
    """Load tool registry"""
    tools_file = Path(__file__).parent / "tools.yml"
    if tools_file.exists():
        with open(tools_file) as f:
            return yaml.safe_load(f)
    return {}

def load_routes():
    """Load routing configuration"""
    routes_file = Path(__file__).parent / "routes.json"
    if routes_file.exists():
        with open(routes_file) as f:
            return json.load(f)["routes"]
    return {}

def load_limits():
    """Load resource limits"""
    limits_file = Path(__file__).parent / "limits.toml"
    if limits_file.exists():
        return toml.load(limits_file)
    return {}

def load_brain():
    """Load brain configuration from brain.rs"""
    brain_file = Path(__file__).parent / "brain.rs"
    if not brain_file.exists():
        return {"name": "UNKNOWN", "type": "Sentinel", "rules": []}
    
    content = brain_file.read_text(encoding="utf-8")
    
    # Parse agent name
    name = "VALIDATOR"
    if 'name: "' in content:
        name = content.split('name: "')[1].split('"')[0]
    
    # Parse brain type
    brain_type = "Sentinel"
    if 'brain: BrainType::' in content:
        brain_type = content.split('brain: BrainType::')[1].split(',')[0]
    
    # Parse rules
    rules = []
    if "Rule::" in content:
        for line in content.split('\n'):
            if "Rule::" in line and not line.strip().startswith('//'):
                rule = line.split("Rule::")[1].split(',')[0].strip()
                rules.append(rule)
    
    return {
        "name": name,
        "type": brain_type,
        "rules": rules
    }

def check_file_limits(filepath):
    """Check if file is within limits"""
    limits = load_limits()
    max_size_mb = limits.get("resources", {}).get("files", {}).get("max_file_size_mb", 100)
    max_size_bytes = max_size_mb * 1024 * 1024
    
    file_size = Path(filepath).stat().st_size
    
    if file_size > max_size_bytes:
        return {
            "within_limits": False,
            "reason": f"File size {file_size} bytes exceeds limit of {max_size_bytes} bytes",
            "file_size_mb": round(file_size / 1024 / 1024, 2),
            "limit_mb": max_size_mb
        }
    
    return {
        "within_limits": True,
        "file_size_mb": round(file_size / 1024 / 1024, 2),
        "limit_mb": max_size_mb
    }

def log_operation(operation, status, details=""):
    """Log operation to 3ox.log"""
    log_file = Path(__file__).parent / "3ox.log"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    sigil = "〘⟦⎊⟧・.°PYTHON.PY〙"
    
    log_entry = f"\n[{timestamp}] {sigil}\n"
    log_entry += f"  Operation: {operation}\n"
    log_entry += f"  Status: {status}\n"
    if details:
        log_entry += f"  Details: {details}\n"
    
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(log_entry)

def route_output(operation, receipt):
    """Route output to destination based on operation type"""
    routes = load_routes()
    destination = routes.get(operation, "0ut.3ox")
    
    # Create destination directory
    dest_path = Path(destination)
    dest_path.mkdir(parents=True, exist_ok=True)
    
    # Write receipt to destination
    receipt_file = dest_path / f"receipt_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    with open(receipt_file, "w") as f:
        f.write(f"Operation: {receipt['operation']}\n")
        f.write(f"File: {receipt['file']}\n")
        f.write(f"Hash: {receipt['hash']}\n")
        f.write(f"Time: {receipt['timestamp']}\n")
        f.write(f"Routed to: {destination}\n")
    
    return destination

def generate_receipt(filepath, operation):
    """Generate operation receipt"""
    result = validate_file(filepath)
    if not result["valid"]:
        return result
    
    receipt = {
        "file": filepath,
        "operation": operation,
        "hash": result["hash"],
        "timestamp": datetime.now().isoformat(),
        "status": "COMPLETE"
    }
    
    # Log to receipt file
    Path("0ut.3ox").mkdir(exist_ok=True)
    with open("0ut.3ox/receipts.log", "a") as f:
        f.write(f"[{receipt['timestamp']}] {operation} | {filepath} | {receipt['hash']}\n")
    
    # Route to destination
    destination = route_output(operation, receipt)
    receipt["routed_to"] = destination
    
    return receipt

def run_test(operation="knowledge_update"):
    """Execute test run with specified operation"""
    print("=" * 60)
    print("3OX TESTRUN :: Python Runtime")
    print("=" * 60)
    
    # Load configuration
    tools = load_tools()
    limits = load_limits()
    brain = load_brain()
    print(f"\n✓ Brain: {brain['name']} ({brain['type']})")
    print(f"✓ Rules: {', '.join(brain['rules'][:3])}")
    print(f"✓ Tools loaded: {len(tools.get('tools', []))} available")
    print(f"✓ Limits loaded: {limits.get('meta', {}).get('version', 'unknown')}")
    
    # Check file limits
    limit_check = check_file_limits(__file__)
    print(f"\n✓ File size: {limit_check['file_size_mb']} MB / {limit_check['limit_mb']} MB")
    print(f"✓ Within limits: {limit_check['within_limits']}")
    
    # Test file validation
    result = validate_file(__file__)
    print(f"\n✓ File: {result['path']}")
    print(f"✓ Hash: {result['hash']}")
    print(f"✓ Size: {result['size']} bytes")
    
    # Generate receipt with custom operation
    receipt = generate_receipt(__file__, operation)
    print(f"\n✓ Receipt: {receipt['status']}")
    print(f"✓ Operation: {operation}")
    print(f"✓ Logged to: 0ut.3ox/receipts.log")
    print(f"✓ Routed to: {receipt['routed_to']}")
    
    # Log to 3ox.log
    log_operation(operation, "COMPLETE", f"Hash: {result['hash']}, Routed to: {receipt['routed_to']}")
    print(f"✓ Operation logged to: 3ox.log")
    
    print("\n" + "=" * 60)
    print("TEST COMPLETE")
    print("=" * 60)
    
    return receipt

# ============================================================================
# Execute
# ============================================================================

def run_batch(operations):
    """Run multiple operations in one session"""
    for operation in operations:
        run_test(operation)
        print("")  # Separator

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 2:
        # Batch mode: multiple operations
        run_batch(sys.argv[1:])
    else:
        # Single mode
        operation = sys.argv[1] if len(sys.argv) > 1 else "knowledge_update"
        run_test(operation)

