
s = 'this thing Is MyString'
s2 = 'String'
s3 = "she is Emma. Emma is good developer. Emma is a writer"

# 1.1 List all chars of a string

def listChars():
    op = ''
    for i in s:
        op = op + i + "\n"
    return op
#print(listChars())

# 1.2 List all chars of a string, separated by commas

def listChars():
    op = ''
    for i in s:
        op = op + i + ","
    return op
#print(listChars())

# 1.3 List all chars of a string, separated by commas, but no comma after the last char

def listChars():
    op = ''
    for i in range(len(s2)):
        if i == len(s2)-1:
            op = op + s2[i]
        else:
            op = op + s2[i] + ","
    return op
#print(listChars())

# 2.1 Separate the words in a string

def words():
    return s.split()
# print(words())

# 2.1 Separate the words in a string and list them with their respective index numbers

def words():
    wlist, eachword, wordlist = [], [], []
    cntr = 0
    wlist = s.split()
    for i in range(len(wlist)):
        eachword = [i, wlist[i]]
        wordlist.append(eachword)
    return  wordlist
#print(words())

# 2.1 print each char of the string with its index number
def iChar():
    op = []
    for i in range(len(s)):
        print([i, s[i]])
    return

# print(iChar())

# 3.1 remove first n chars
def removeFirstn():
    n = 5
    op = s[n:]
    return op
#print(removeFirstn())

# 4.1 count 'Emma' in a string
def countEmma():
    em = s3.count("Emma")
    return em
#print(countEmma())

# 4.2 count 'Emma' in a string without using the count method

def cntEmma():
    em = "Emma"
    mcnt = 0
    spos, start = 0, 0
    for i in range(start, len(s3)):
        if s3.find(em, spos) >= 0:
            mcnt = mcnt + 1
            spos = s3.find(em, spos+len(em))
            print(spos, mcnt, s3[spos:])
    return

#print(cntEmma())

# 4.3 find 'Emma' indexes in a string without using the find method
def empos():
    em = 'Emma'
    op = []
    for i in range(len(s3)):
        if s3.find(em, i) >=0:
            print(s3.find(em, i))
    return

print(empos())


