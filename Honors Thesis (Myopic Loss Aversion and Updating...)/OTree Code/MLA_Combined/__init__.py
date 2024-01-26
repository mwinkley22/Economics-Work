
from otree.api import *
c = cu

doc = ''
class C(BaseConstants):
    NAME_IN_URL = 'MLA_Combined'
    PLAYERS_PER_GROUP = None
    NUM_ROUNDS = 200
    MY_CONSTANT = ()
class Subsession(BaseSubsession):
    pass
def creating_session(subsession: Subsession):
    session = subsession.session
    if subsession.round_number == 1:
        import itertools
        treatment_group = itertools.cycle([1, 2, 3, 4])
        for player in subsession.get_players():
            player.treatment_group_flag = next(treatment_group)
    
    
    
class Group(BaseGroup):
    pass
class Player(BasePlayer):
    fund_a_allocation = models.FloatField()
    fund_b_allocation = models.FloatField()
    combined_realized = models.FloatField()
    treatment_group_flag = models.IntegerField()
class Introduction(Page):
    form_model = 'player'
class Decision(Page):
    form_model = 'player'
    form_fields = ['fund_a_allocation']
class Results(Page):
    form_model = 'player'
    @staticmethod
    def js_vars(player: Player):
        return dict()
page_sequence = [Introduction, Decision, Results]
