final croatianAlphabet = ['a', 'b', 'c', 'č', 'ć', 'd', 'dž', 'đ', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'lj', 'm', 'n', 'nj', 'o', 'p', 'r', 's', 'š', 't', 'u', 'v', 'z', 'ž'];

int croatianSort(String a, String b) 
{
  final len = a.length < b.length ? a.length : b.length;

  for (var i = 0; i < len; i++) {
    final charA = a[i].toLowerCase();
    final charB = b[i].toLowerCase();

    final indexA = croatianAlphabet.indexOf(charA);
    final indexB = croatianAlphabet.indexOf(charB);

    if (indexA != -1 && indexB != -1) 
    {
      if (indexA != indexB) 
      {
        return indexA - indexB;
      }
    }
     else if (indexA != -1) 
    {
      return -1;
    }
     else if (indexB != -1) 
    {
      return 1;
    }
    else
    {
      final compare = charA.compareTo(charB);
      if (compare != 0) 
      {
        return compare;
      }
    }
  }

  return a.length - b.length;
}
