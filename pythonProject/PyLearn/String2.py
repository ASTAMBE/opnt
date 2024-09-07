#8.1 remove duplicates
s = 'this has many many dupes has it not'
n = 100367

def nodupe():
    # first split the string - this will give words. put them in a set. this will remove dupes
    words = []
    nd = set()
    for word in s.split():
        nd.add(word)
    print(nd)

#print(nodupe())

def onlyOdds():
    modn = abs(n)
    if modn == 0:
        return None
    for i in str(modn):
        
        print(i, '-', int(i))
    return

print(onlyOdds())