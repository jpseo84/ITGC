import os
import hashlib

def verify_file_integrity():
    # Records verification results for each file
    results = {}
    
    # Iteration - for files in the current directory using "output_n.txt" format
    for file_name in sorted(os.listdir()):
        if file_name.startswith("output_") and file_name.endswith(".txt"):
            
            # Recalculate hash for each file
            with open(file_name, 'r') as file:
                lines = file.readlines()
                content = ''.join(lines[:-1])
                stored_hash = lines[-1].split(":")[1].strip()
            computed_hash = hashlib.sha256(content.encode()).hexdigest()
            
            # Compare the computed hash against the hash read from the last line of each file
            if computed_hash == stored_hash:
                results[file_name] = "Integrity intact"
            else:
                results[file_name] = "Integrity compromised"
                
    return results

verification_results = verify_file_integrity()

# Print results
for file_name, result in verification_results.items():
    print(f"{file_name}: {result}")
