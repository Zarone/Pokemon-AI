import os 
import pickle

dir_path = os.path.dirname(os.path.realpath(__file__))

def parse_rawPokedex(raw_file='{}/data/raw_pokedex.txt'.format(dir_path)):
    import demjson

    with open(raw_file, "r") as f:
        raw_contents = f.readlines()
    new_lines = []
    for raw_line in raw_contents:
        raw_line = raw_line.replace("export const Pokedex: {[speciesid: string]: SpeciesData} = ","")
        raw_line = raw_line.replace(";","")
        new_lines.append(raw_line)
    new_lines[-2] = "}"
    contents = " ".join(new_lines)
    
    parsed_json = demjson.decode(contents)
    pokedex = {parsed_json[i]["name"] : parsed_json[i] for i in parsed_json.keys()}
    print("Writing {}/data/pokedex.pickle".format(dir_path))
    with open('{}/data/pokedex.pickle'.format(dir_path), 'wb') as handle:
        pickle.dump(pokedex, handle, protocol=pickle.HIGHEST_PROTOCOL)

    return pokedex

class Pokedex:
    def __init__(self):
        try:
            with open('{}/data/pokedex.pickle'.format(dir_path), 'rb') as f:
                self.pokedex = pickle.load(f)
        except:
            print("Couldn't open pokedex.pickle\nCreating New Pickle (takes a while)")
            self.pokedex = parse_rawPokedex()

    def get_poke(self, name):
        """
        Returns the items within self.pokedex[name]
        Using a separate function for easier error handling (may have to manually redirect some edge cases)
        """
        if name in self.pokedex:
            return self.pokedex[name]
        else:
            return None

if __name__ == '__main__':
    pdex = Pokedex()
    print(pdex.get_poke("Bulbasaur"))


