import glob
import itertools

#Read all the files ending with .txt
read_files = glob.glob("*.txt")

#Create a new file called combinedpeople and
#write all the txt files into it
with open("combinedpeople.txt", "wb") as outfile:
    for f in read_files:
        with open(f, "rb") as infile:
            outfile.write(infile.read())

#Create another file with only the unique records
# outfile = open("UniquePeopleMasterList.txt", "w", encoding = "latin-1")
with open("combinedpeople.txt", "r", encoding = "latin-1") as infile:
    sorted_file = sorted(infile.readlines())
# for line, _ in itertools.groupby(sorted_file):
#     outfile.write(line)

#We open both input and output files
file_in = "combinedpeople.txt"
file_out = "UniquePeopleMasterList.txt"

with open(file_in, 'r') as f_in, open(file_out, 'w') as f_out:
    # Skip header
    next(f_in)
    # Find duplicated hashes
    hashes = set()
    hashes_dup = {}
    for row in f_in:
        h = hash(row)
        if h in hashes:
            hashes_dup[h] = set()
        else:
            hashes.add(h)
    del hashes
    # Rewind file
    f_in.seek(0)
    # Copy header
    f_out.write(next(f_in))
    # Copy non repeated lines
    for row in f_in:
        h = hash(row)
        if h in hashes_dup:
            dups = hashes_dup[h]
            if row in dups:
                continue
            dups.add(row)
        f_out.write(next(f_in))