def strPos(str1):
    word = 'good'
    pos, startpos, wcount, i = 0, 0, 0, 0
    wordpos = []
    wcount = str1.count(word)
    while i < wcount:
        pos = str1.find(word, startpos)
        wordpos.append(pos)
        startpos = pos + len(word)
        i += 1
    return len(wordpos)


#print(strPos('hey good it is goodgood is it very good really good g o o good o'))

def longestNoRepeat(str2):
    ''' To find the longest non-repeating substring, here is the plan of code
    take the second letter of the string and compare it to the first letter
    if they are the same then go to the next letter and compare it to its previous.
    if they do not match then increment the length of the long string and go to the next
    letter.
    '''
    startpos, longest = 0,0
    for i in range(len(str2)):
        if str2[i+1] == str2[i]:
            1 += 1
        else:

