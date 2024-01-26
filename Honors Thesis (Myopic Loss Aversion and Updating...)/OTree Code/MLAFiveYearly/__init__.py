
from otree.api import *
c = cu

doc = ''
class C(BaseConstants):
    NAME_IN_URL = 'Experiment_FiveYearly1'
    PLAYERS_PER_GROUP = None
    NUM_ROUNDS = 5
    A_RETURNS = (0.091, 0.099, 0.102, 0.122, 0.116, 0.113, 0.113, 0.102, 0.102, 0.101, 0.117, 0.121, 0.091, 0.109, 0.124, 0.123, 0.125, 0.104, 0.109, 0.101, 0.108, 0.109, 0.111, 0.118, 0.093, 0.103, 0.11, 0.117, 0.101, 0.093, 0.107, 0.11, 0.127, 0.095, 0.111, 0.114, 0.128, 0.11, 0.147, 0.1, 0.1, 0.094, 0.115, 0.101, 0.132, 0.113, 0.09, 0.112, 0.11, 0.114, 0.101, 0.108, 0.119, 0.097, 0.098, 0.114, 0.111, 0.096, 0.117, 0.103, 0.12, 0.1, 0.1, 0.114, 0.12, 0.094, 0.098, 0.11, 0.104, 0.101, 0.119, 0.117, 0.109, 0.125, 0.105, 0.107, 0.124, 0.098, 0.107, 0.115, 0.102, 0.101, 0.114, 0.113, 0.109, 0.094, 0.128, 0.092, 0.099, 0.11, 0.1, 0.153, 0.099, 0.105, 0.101, 0.125, 0.121, 0.141, 0.111, 0.101)
    B_RETURNS = (0.41, 0.437, 0.19, 0.534, 0.738, 0.269, 0.436, 0.363, 0.416, 0.702, 0.697, 0.795, 0.278, 0.357, 0.402, 0.113, 0.996, 0.118, 0.148, 0.619, 0.191, 0.343, -0.024, 0.741, 0.412, 1.176, 1.85, 0.406, 0.194, 0.265, 0.55, 0.765, 0.399, 0.674, 0.514, 0.119, 0.43, 0.237, 1.409, -0.066, 0.569, 0.254, 0.354, -0.029, 0.753, 0.705, 0.807, 0.137, 0.474, 0.208, 0.704, 0.224, 0.661, 0.402, 0.417, 1.03, 0.457, 0.794, 0.023, 0.079, 0.49, 0.614, 0.266, 0.505, 0.764, 0.774, -0.059, 0.302, -0.062, 0.324, 0.334, 0.424, 0.641, 0.434, 0.692, 0.097, 0.6, 0.558, 0.606, 0.076, 0.475, 0.834, 0.431, -0.071, 0.214, 0.237, 0.327, 0.614, 0.664, 0.229, 0.296, 0.58, 0.736, 0.906, 0.38, 0.136, -0.137, 0.191, 0.43, 0.261)
class Subsession(BaseSubsession):
    pass
class Group(BaseGroup):
    pass
class Player(BasePlayer):
    fund_a_allocation = models.IntegerField(max=100, min=0)
    fund_a_realized = models.FloatField()
    fund_b_realized = models.FloatField()
    combined_realized = models.FloatField()
    debrief_accepted = models.BooleanField()
    email_address = models.StringField()
class Consent_Form(Page):
    form_model = 'player'
    form_fields = ['email_address']
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number==1
class Introduction(Page):
    form_model = 'player'
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number==1
class Decision(Page):
    form_model = 'player'
    form_fields = ['fund_a_allocation']
class Results(Page):
    form_model = 'player'
    @staticmethod
    def js_vars(player: Player):
        group = player.group
        
        fund_a_return_calc=C.A_RETURNS[(20*(player.id_in_group-1))+player.round_number-1]
        fund_b_return_calc=C.B_RETURNS[(20*(player.id_in_group-1))+player.round_number-1]
        combined_return_calc=fund_a_return_calc*(player.fund_a_allocation)/100 + fund_b_return_calc*(100-player.fund_a_allocation)/100
        player.combined_realized = combined_return_calc
        return dict(
                fund_b_return=round(fund_b_return_calc,3),
        fund_a_return=round(fund_a_return_calc,3),
            combined_return= round(combined_return_calc,3)
        )
class Debrief(Page):
    form_model = 'player'
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number==5
page_sequence = [Consent_Form, Introduction, Decision, Results, Debrief]
