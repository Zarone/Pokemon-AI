#!/usr/bin/env python3

import mock
import unittest

from src.ShowdownLog import ShowdownLog
from src.Trainer import Trainer
from src.Battle import Battle

@mock.patch('src.Battle')
class TestCase(unittest.TestCase):
    def test_trainer_init(self, out): 
        self.assertRaises(AttributeError, Trainer, "Player1", [])
        self.assertRaises(AttributeError, Trainer, "Player1", ['1','2','3','4','5','6','7'])
        self.assertTrue(Trainer('Player1', ['1','2','3','4','5','6']).name == 'Player1')
        self.assertTrue(list(Trainer('Player1', ['1','2','3','4','5','6']).team.keys()) == ['1','2','3','4','5','6'])

    def test_battle_init(self, out):
        t1 = Trainer("Player1", ["Poke1","Poke2","Poke3","Poke4","Poke5","Poke6"])
        t2 = Trainer("Player2", ["Gary","Red","Blue","Green","Yella","Purp"])
        battle = Battle(t1, t2)
        self.assertTrue(battle.trainer1 == t1)
        self.assertTrue(battle.trainer2 == t2)
        
unittest.main()        
