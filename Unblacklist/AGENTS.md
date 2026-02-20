# AGENTS.md

This file provides guidance for agentic coding agents working on the 3CX Unblacklist repository.

## Project Overview

This is a simple bash script-based utility for removing blacklisted IP addresses from 3CX phone systems running on Ubuntu. The project consists of a single bash script (`unblacklist.sh`) that interacts with the 3CX PostgreSQL database to delete entries from the blacklist table.

## Build/Test/Development Commands

This is a pure bash script project with no complex build system:

### Testing the Script
```bash
# Test the script with dry-run (no actual database operations)
./unblacklist.sh

# To run individual components, source the script and test functions:
source unblacklist.sh
validateIpAddress "192.168.1.1"  # Should return 0 (valid)
validateIpAddress "invalid.ip"   # Should return 1 (invalid)
```

### Code Quality
```bash
# Shell syntax check
bash -n unblacklist.sh

# Check for shell script best practices
shellcheck unblacklist.sh  # if shellcheck is installed
```

### Installation/Deployment
```bash
# Make script executable
chmod +x unblacklist.sh

# Copy to system location (optional)
sudo cp unblacklist.sh /usr/local/bin/unblacklist
```

## Code Style Guidelines

### Bash Scripting Conventions

#### Function Definitions
- Use `function functionName() {` syntax with consistent spacing
- Include inline comments describing function purpose and usage
- Place all function definitions at the top of the file before the main section

```bash
# Example function style
function validateIpAddress() {
    local ip=$1
    # Function implementation
}
```

#### Variable Naming
- Use `camelCase` for local variables: `ip_addr`, `DBPassword`
- Use `UPPER_CASE` for constants and environment variables
- Use descriptive names that clearly indicate purpose
- Always use `local` for variables inside functions

#### Error Handling
- Check command exit codes with `$?`
- Exit gracefully with meaningful error messages
- Validate user input before processing
- Use conditional statements to handle edge cases

```bash
if [[ $? -eq 1 ]]; then
    echo "Error message describing what went wrong"
    exit 1
fi
```

#### Code Organization
- Structure files with clear section headers using comment blocks
- Order: Functions first, then main execution
- Use consistent indentation (4 spaces recommended)
- Add blank lines between logical sections

#### Comments and Documentation
- Use `#` for single-line comments
- Create section headers with decorative characters:
```bash
#####################
# F U N C T I O N S #
#####################
```
- Document function usage in comments above function definitions
- Include author, version, and date information at the top

#### String Handling and Quoting
- Always quote variables: `"$ip_addr"` not `$ip_addr`
- Use `[[ ]]` for conditional tests instead of `[ ]`
- Quote command substitutions: `$(command)` format

#### Database Operations
- Use heredoc syntax for SQL commands to improve readability
- Validate database connectivity before operations
- Handle database errors gracefully
- Use parameterized queries when possible (avoid SQL injection)

#### User Interaction
- Use `read -rp` for user prompts (shows prompt and accepts input)
- Provide clear instructions and feedback
- Include version information in user-facing output
- Display next steps after successful operations

## Project-Specific Considerations

### Dependencies
- Requires `psql` (PostgreSQL client) to be installed
- Must be run with appropriate permissions to access 3CX files
- Assumes 3CX is installed in `/var/lib/3cxpbx/`

### Security
- Script reads sensitive database password from system files
- Ensure proper file permissions on the script
- Consider additional input validation for production use
- Database credentials should be handled securely

### Testing Strategy
- Test IP address validation with various valid/invalid inputs
- Verify database connection and error handling
- Test with missing or corrupted configuration files
- Validate user input edge cases

## Development Workflow

1. Make changes to `unblacklist.sh`
2. Run syntax check: `bash -n unblacklist.sh`
3. Test manually with sample data
4. Verify error conditions are handled properly
5. Update documentation if needed
6. Commit changes with descriptive messages

## File Structure

```
/
├── unblacklist.sh    # Main script file
├── README.md         # Project documentation
├── TODO              # Future improvements list
└── AGENTS.md         # This file - agent guidelines
```

This is a minimal project focused on a single utility script. Keep changes simple and maintain backward compatibility with existing 3CX installations.