list1 = ['p', 'q', 'r']
list2 = [1,2,3]
d1 = {'a': 10, 'b': 20, 'c': 30, 'd': 30, 'e': 40}
strings = ["apple", "bat", "car", "dog", "elephant", "guava"]
stnc = "this is a test this is only a test"
dict1 = {'a': 100, 'b': 200, 'c': 300}
dict2 = {'a': 300, 'b': 200, 'd': 400, 'e': 125}

def mrgplus():
    added = {}
    for k,v in dict1.items():
        if k in added:
            added[k]= added[k]+ v
        else:
            added[k] = v
    for k,v in dict2.items():
        if k in added:
            added[k]= added[k]+ v
        else:
            added[k] = v
    return added
print(mrgplus())

def l2dict():
    l2d = {}
    for i, j in zip(list1, list2):
        l2d[i] = j
    return l2d

#print(l2dict())

#sum values in a dict
def sumd():
    sumofd = 0
    for key in d1:
        sumofd += d1[key]
    return sumofd

#print(sumd())

#sum the 1,3 and 5th values in a dict

def d135sum():
    keynum = {}
    target = [1,3,5]
    kc, ksum = 0, 0
    for key in d1:
        kc += 1
        keynum[kc] = key
    for key in keynum:
        if key in (target):
            ksum += d1[keynum[key]]
    return ksum

#print(d135sum())

# find the first and the last kv from dict

def rvd():
    drev = {}
    for key in reversed(d1):
        drev[key] = d1[key]
    return drev

#print(rvd())

#group by length of strings
def strtodict():
    strlen, lcnt = 0, 0
    frutlen = {}
    frutcom = {}
    frut = []
    for i in strings:
        frutlen[i] = len(i)
    for k,v  in frutlen.items():
        if v in frutcom:
            frutcom[v].append(k)
        else:
            frutcom[v] = [k]
    return frutcom

#print(strtodict())

#Count the Frequency of Words in a Sentence

def wfreq():
    freq = {}
    for i in stnc.split():
        if i not in freq:
            freq[i] = 1
        else:
            freq[i] += 1
    return freq

#print(wfreq())


