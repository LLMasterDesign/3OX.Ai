# CORE.3ox EXAMPLES
**Purpose:** Practical usage examples  
**Version:** v1.1.0

---

## Basic Usage

### Example 1: Single File Validation

```bash
ruby .3ox/run.rb knowledge_update
```

**Output:**
```
🔓 ACTIVATION KEY VERIFIED
━━━━━━━━━━━━━━━━━━━━━━
Agent: GUARDIAN
Runtime: ruby
Status: UNLOCKED
━━━━━━━━━━━━━━━━━━━━━━

✓ Brain: GUARDIAN (Sentinel)
✓ Rules: AtomicOpsOnly, AlwaysBackup, ChecksumValidation
✓ Tools loaded: 4 available
✓ File validated
✓ Receipt generated
✓ Routed to: OBSIDIAN.BASE
```

---

### Example 2: Batch Operations (FAST)

```bash
ruby .3ox/run.rb critical_error deploy_ready sync_request
```

**Result:** 3 operations in ~2 seconds (vs 13 seconds separately)

---

### Example 3: Emergency Routing

```bash
ruby .3ox/run.rb emergency
```

Routes critical files to `CMD.BRIDGE/EMERGENCY` for immediate attention.

---

## Advanced Usage

### Custom Routing

Edit `.3ox/routes.json` to add custom destinations:

```json
{
  "routes": {
    "client_files": "CLIENTS/ACTIVE",
    "archive": "ARCHIVE/2025",
    "backup": "BACKUPS/DAILY"
  }
}
```

Then:
```bash
ruby .3ox/run.rb client_files
```

---

### Check Your Machine ID

```bash
ruby .3ox/generate_key.rb machine_id
```

**Output:** `Current Machine ID: 23ad0ab7565592cb`

Use this when requesting license transfers.

---

### Generate Test Key (Vendors Only)

```bash
ruby .3ox/generate_key.rb --to="Company Name" --expires="2026-12-31"
```

Creates signed, machine-bound key that expires Dec 31, 2026.

---

## Integration Examples

### Shell Script Integration

```bash
#!/bin/bash
# Automated file validation pipeline

ruby .3ox/run.rb knowledge_update
ruby .3ox/run.rb deploy_ready
ruby .3ox/run.rb sync_request

echo "Pipeline complete"
```

---

### Cron Job (Automated Backups)

```cron
# Daily validation at 2 AM
0 2 * * * cd /path/to/CORE.3ox && ruby .3ox/run.rb sync_request
```

---

### PowerShell Integration

```powershell
# Validate all files in folder
Get-ChildItem *.txt | ForEach-Object {
    ruby .3ox/run.rb knowledge_update
}
```

---

## Troubleshooting

### "ACTIVATION KEY MISSING"

**Problem:** No 3ox.key file found  
**Solution:** Place your license key in `.3ox/` folder

### "MACHINE ID MISMATCH"

**Problem:** Key is bound to different machine  
**Solution:** Contact license@3ox.ai for transfer

### "LICENSE EXPIRED"

**Problem:** Key expiration date passed  
**Solution:** Renew license or contact sales

### "KEY SIGNATURE INVALID"

**Problem:** Key file was edited/tampered  
**Solution:** Request fresh key from vendor

---

## Performance Tips

**Use batch mode for multiple operations:**
```bash
# SLOW (3x startup overhead)
ruby .3ox/run.rb op1
ruby .3ox/run.rb op2
ruby .3ox/run.rb op3

# FAST (1x startup)
ruby .3ox/run.rb op1 op2 op3
```

**Check logs for operation history:**
```bash
cat .3ox/3ox.log
```

**View receipts:**
```bash
cat .3ox/0ut.3ox/receipts.log
```

---

:: ∎

