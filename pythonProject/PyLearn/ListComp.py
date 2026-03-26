#numbers from 1-20 that are divisible by 3 and 5

def list35():
    listof35 = [x for x in range(20) if x % 3 == 0 and x %5 == 0]
    return listof35

print(list35())