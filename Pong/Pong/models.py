from turtle import *
from consts import *
import winsound

class Paddle(Turtle):
    """

    """
    def __init__(self, w, ctrl, h):
        """
        """
        #assert type(w) == Screen
        assert type(h) == bool
        assert type(ctrl) == list
        for i in range(len(ctrl)):
            assert type(ctrl[i]) == str
            assert len(ctrl[i]) > 0

        super().__init__()
        self.penup()
        self.speed(GSPEED)
        self.color(COLOR2)
        self.shape("square")
        self.shapesize(PAD_LEN, PAD_WID)

        self._control = ctrl
        self._hit = h
    
    def moveUp(self):
        self.sety(self.ycor() + PAD_STEP)

    def moveDown(self):
        self.sety(self.ycor() - PAD_STEP)

    def toggleHit(self):
        if self._hit == True:
            self._hit = False
        else:
            self._hit = True

    def canHit(self):
        return self._hit

class Ball(Turtle):
    """

    """
    def __init__(self):
        """
        """
        super().__init__()
        self.penup()
        self.speed(GSPEED)
        self.color(COLOR2)
        self.shape("square")
        self.shapesize(BALL_WID, BALL_LEN)
        self.hideturtle()

        self._active = False
    
    def move(self, x, y):
        """
        """
        self.setx(self.xcor() + x)
        self.sety(self.ycor() + y)

    def reset(self):
        """
        """
        self.setpos(0,0)

    def toggleActive(self):
        """
        """
        if (self._active == False):
            self.showturtle()
            self._active = True
        else:
            self.hideturtle()
            self._active = False

    def isActive(self):
        """
        """
        return self._active

    def isCollidingWithPaddle(self, p, dir):
        """
        """
        assert type(p) == Paddle
        assert dir == 1 or dir == -1

        if (self.xcor() + dir*BALL_WID*10 > p.xcor() - PAD_WID*10)\
        and (self.xcor() + dir*BALL_WID*10 < p.xcor() + PAD_WID*10) and (p.canHit() == True)\
        and (self.ycor() + BALL_LEN*10 < p.ycor() + PAD_LEN*10)\
        and (self.ycor() - BALL_LEN*10 > p.ycor() - PAD_LEN*10):
            return True
        return False
    
    def isOnScreen(self):
        """
        """
        if (self.xcor() - BALL_WID*10 > WINDOW_WIDTH/2) or\
        (self.xcor() + BALL_WID*10 < -WINDOW_WIDTH/2):
            return False
        return True

class Controller(Turtle):
    """
    """
    def __init__(self):
        super().__init__()
        self.hideturtle()
        self.speed(GSPEED)
        self.color(COLOR2)
        self.penup()
        self._score = [0, 0]
        self.drawScore()

    def drawScore(self):
        """
        """
        t = (str(NAME[0]) + ": " + str(self._score[0]) + "\t||\t"\
        + str(NAME[1] + ": " + str(self._score[1])))

        self.sety(WINDOW_HEIGHT/2 - WINDOW_HEIGHT/10)
        self.write(t, align = "center", font = (FONT_NAME, FONT_SIZE, FONT_TYPE))

    def scorePoint(self, i):
        """
        """
        assert i == 0 or i == 1
        self._score[i] += 1
        winsound.PlaySound(str(SOUNDFONT[1]), winsound.SND_ASYNC)

    def playBounceSound(self):
        """
        """
        winsound.PlaySound(str(SOUNDFONT[0]), winsound.SND_ASYNC)

    