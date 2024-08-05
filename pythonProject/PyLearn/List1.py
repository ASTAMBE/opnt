l1 = [6, 4, 8, 66, 2, 66, 3, 8, 9, 22, 29, 9]
l2 = ['abc', 'xyz', 'aba', '1221']
def lmax():
    result = l1[0]
    var = 0
    for i in l1:
        if i >= var:
            var = i

    return var
print(lmax())

def nodupe():
    ndl = []
    for i in l1:
        if i not in ndl:
            ndl.append(i)
    return ndl
print(nodupe())

def longestIncr():
    le, breaks = [], []
    lenToStr = {}
    for i in range(len(l1)-1):
        if l1[i] >= l1[i+1]:
            breaks.append(i+1)
            lenToStr.update({i+1:l1[i+1]})
    return breaks, lenToStr
print(longestIncr())

