l1 = [6, 4, 8, 66, 2, 66, 3, 8, 9, 22, 29, 9]
l2 = ['abc', 'xyz', 'aba', '1221']
def lmax():
    result = l1[0]
    var = 0
    for i in l1:
        if i >= var:
            var = i

    return var
#print(lmax())

def nodupe():
    ndl = []
    for i in l1:
        if i not in ndl:
            ndl.append(i)
    return ndl
#print(nodupe())

def longestIncr():
    le, breaks = [], []
    lenToStr = {}
    for i in range(len(l1)-1):
        if l1[i] >= l1[i+1]:
            breaks.append(i+1)
            lenToStr.update({i+1:l1[i+1]})
    return breaks, lenToStr
#print(longestIncr())

# make the two lists of equal size by popping the items from the longer list

def eql(l1, l2):
    newl1, newl2 = [], []
    l1len = len(l1)
    l2len = len(l2)
    if l1len > l2len:
        while l2len < l1len:
            l1.pop()

    elif l2len > l1len:
        while l1len < l2len:
            l2.pop()

    return l1, l2

print(eql(l1, l2))
