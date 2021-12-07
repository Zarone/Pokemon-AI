
from bs4 import BeautifulSoup, SoupStrainer
import requests

REPLAY_URL = "https://replay.pokemonshowdown.com/"
NUMBER_FILTERED_LINKS = 50

def parse_replaylinks(match_string=None, unmatch_string=None):
    """
    Parse the Pokemon Showdown replays URL, filter out the recent 50
    Apply match and unmatch filters
    Returns list of links

    Usage: 
        parse_replaylinks(match_string="ou", unmatch_string="doubles")
        parse_replaylinks(match_string="gen8")
    """
    page = requests.get(REPLAY_URL)    
    data = page.text
    soup = BeautifulSoup(data,features="lxml")

    link_list = []
    for link in soup.find_all('a'):
        link_list.append(link.get('href'))

    # Filter last 50 links (corresponds to recent replays)
    link_list = link_list[-NUMBER_FILTERED_LINKS:]

    # Apply input filters
    if match_string:
        link_list = [l for l in link_list if match_string in l]
    if unmatch_string:
        link_list = [l for l in link_list if unmatch_string not in l]

    return link_list

