import csv

lista_tipos = ['Dragao','Fantasma','Pedra','Inseto','Voador','Terra','Veneno','Lutador','Gelo','Grama','Fogo','Agua','Eletrico','Normal']

# First read all existing entries
existing_entries = []
try:
    with open('./eficiencias.csv', mode='r') as file:
        csv_reader = csv.reader(file)
        for row in csv_reader:
            if len(row) >= 2:
                existing_entries.append((row[0], row[1]))
except FileNotFoundError:
    pass  # File doesn't exist yet, we'll create it

# Now append missing entries
with open('./eficiencias.csv', mode='a', newline='') as file:
    csv_writer = csv.writer(file)
    for e1 in lista_tipos:
        for e2 in lista_tipos:
            if (e1, e2) not in existing_entries:
                csv_writer.writerow([e1, e2, '1.0'])
