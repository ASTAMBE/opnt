# find frequent char in a string
s = "felicitation"
s1 = 'bear'
s2 = 'bare'
s3 = 'rare'
def fqnt():
    char_count = {}
    for char in s:
        if char in char_count:
            char_count[char] += 1
        else:
            char_count[char] = 1
    max_key = max(char_count, key=char_count.get)
    print(max_key)

#print(fqnt())

# find all chars in a string without using the dict

def allchars():
    chars = []
    for char in s:
        if char not in chars:
            chars.append(char)
    print(chars)

#print(allchars())

# CHECK IF TWO STRINGS ARE ANAGRAMS

def anag(st1, st2):
    if len(st1) != len(st2):
        print(f"'{st1}' and '{st2}' are not anagrams.")
    else:
        st1char, st2char = [], []
        for i, j in zip(st1, st2):
            st1char.append(i)
            st2char.append(j)
        if sorted(st1char) == sorted(st2char):
            print(f"'{st1}' and '{st2}' are anagrams")
        else:
            print(f"'{st1}' and '{st2}' are NOT anagrams")

print(anag(s1, s2))

