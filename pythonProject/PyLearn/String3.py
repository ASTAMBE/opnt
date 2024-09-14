# if a string is symmetric - symmetric = both halves are same
# we are assuming that if string as odd num of chars then the symmetry is when the two halves beyond the middle char are same

def strSym(str1):
    half1, half2 = '', ''

    if len(str1) % 2 == 1:
        half1 = str1[0:len(str1)//2]
        half2 = str1[len(str1)//2+1:]
        if half1 == half2:
            print(f'the string {str1} is symmetric with each half = {half1}')
        else:
            print(f'the string {str1} is not symmetric')
    else:
        half1 = str1[0:int(len(str1)/2)]
        half2 = str1[int(len(str1)/2):]
        if half1 == half2:
            print(f'the string {str1} is symmetric with each half = {half1}')
        else:
            print(f'the string {str1} is not symmetric')

#print(strSym('abcabc'))

def palin(str1):
    forward, backward = '', ''
    forward = str1[0:len(str1)]
    backward = str1[len(str1)+1::-1]
    if forward == backward:
        print(f'the string {str1} is a palindrome')
    else:
        print(f'the string {str1} is not a palindrome')

#print(palin('abcdedcba'))

def wtonum(numAsStr):
    wnum = {'zero':0, 'one':1, 'two':2, 'three':3, 'four':4}
    words = []
    tonum = ''
    words += numAsStr.split(' ')
    for word in words:
        if word in wnum.keys():
            tonum += str(wnum[word])
    print(int(tonum))

#print(wtonum('one and two and three'))

def wordposn(str1):
    word = 'good'
    posn = []
    startpos = 0
    for
    posn += str1.find(word, startpos)