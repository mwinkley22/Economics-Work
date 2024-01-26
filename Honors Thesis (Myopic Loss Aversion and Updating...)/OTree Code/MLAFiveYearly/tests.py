import MLAFiveYearly as pages
from . import *
c = cu

class PlayerBot(Bot):
    def play_round(self):
        if self.player.round_number==1:
            yield Consent_Form, dict(email_address="xyz")
        if self.player.round_number==1:
            yield Introduction
        yield Decision, dict(fund_a_allocation=100)
        yield Results
        if self.player.round_number==5:
            yield Debrief, dict(debrief_accepted=False)