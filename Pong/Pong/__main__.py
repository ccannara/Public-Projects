from turtle import Screen
from models import *
from consts import *

w = Screen()
w.title("Pong")
w.bgcolor(COLOR1)
w.setup(WINDOW_WIDTH, WINDOW_HEIGHT)

p1 = Paddle(w, PAD_CTRL[0], False)
p2 = Paddle(w, PAD_CTRL[1], True)
p1.setx(-PAD_OFFSET)
p2.setx(PAD_OFFSET)

x = BALL_XSTEP
y = BALL_YSTEP

ball = Ball()
ctr = Controller()

w.listen()
w.onkey(p1.moveUp, p1._control[0]); w.onkey(p1.moveDown, p1._control[1])
w.onkey(p2.moveUp, p2._control[0]); w.onkey(p2.moveDown, p2._control[1])

ball.toggleActive()
ctr.drawScore()


while True:
    w.update()

    ball.move(x, y)

    if (ball.ycor() + BALL_LEN*10 > ((WINDOW_HEIGHT/2))):
        ball.sety(((WINDOW_HEIGHT/2) - BALL_LEN*10))
        y *= -1
        ctr.playBounceSound()
    elif (ball.ycor() - BALL_LEN*10 < (-WINDOW_HEIGHT/2)):
        ball.sety(((-WINDOW_HEIGHT/2) + BALL_LEN*10))
        y *= -1
        ctr.playBounceSound()

    if ball.isCollidingWithPaddle(p2, 1) == True or ball.isCollidingWithPaddle(p1, -1) == True:
        x *= -1.15
        y *= 1.05
        p1.toggleHit(); p2.toggleHit()
        ctr.playBounceSound()
    
    if ball.isOnScreen() == False:
        if (ball.xcor() + BALL_WID*10 > WINDOW_WIDTH/2):
            ctr.scorePoint(0)
        else:
            ctr.scorePoint(1)
        ctr.clear()
        ctr.drawScore()

        p1.sety(0)
        p2.sety(0)
        ball.reset(); x *= -1; y *= 1
        if (x > 0):
            x = BALL_XSTEP
        else:
            x = -BALL_XSTEP
        if (y > 0):
            y = BALL_YSTEP
        else:
            y = -BALL_YSTEP
        p1.toggleHit(); p2.toggleHit()