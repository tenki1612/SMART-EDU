with open('backend/seed.py', 'r', encoding='utf-8') as f:
    for i, line in enumerate(f, 1):
        if 'cls1 =' in line or 'IELTS-65-K26A' in line or 'c1 =' in line:
            print(f"{i}: {line.strip()}")
