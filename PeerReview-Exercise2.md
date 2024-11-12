## Peer-reviewer Information

* *name:* Jose Miguel Romero
* *email:* jmmromero@ucdavis.edu

This was reviewed in a technical standpoint for the checkmarks on a basis if the checklists were
completed. 

### Stage 1 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

#### Justification ##### 
The camera is perfectly locked on to the ball. There's nothing complicated about this one as all they needed was to make the camera global
position equal the target global position and they did so. There is also a 5x5 cross at the center when pressing F, so all steps were
completed.

### Stage 2 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

#### Justification ##### 
The camera is working perfectly and is auto scrolling while keeping the target contained in it's rectangle. It's cool to see that they
used a ray cast in order to make the box expand or decrease so that it's always at the edges of the screen. I didn't do it like that
and instead had a premade rectangle that always stays the same, so this implementation is much better. You can also see the box expand and
decrease when you can see the box and it's always accurate.

### Stage 3 ###

- [ ] Perfect
- [x] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

#### justification ##### 
While the camera works very similarly to what was wanted, I did notice that the leash distance us actually a square and not a circle.
This means that the leash distance only ever appears to reach it's max in the corners, the front and side edges being much shorter.
This is because this uses the same code as the push box camera but with leash distance included instead of box_width.
The way I would go around that is to check the leash distance is more than the target position minus the camera position, since
the player is always ahead in this specific camera. Then you can set the camera global position right where the leash is maximized.
Other than that this is a perfectly reasonable implementation with a very minor flaw.

### Stage 4 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

#### justification ##### 
This camera works perfectly and meets all the criteria. It focuses on the target after a few seconds using a Timer called catchup_timer.
All of the speeds are working, so the catch up speed and the lead speed. One thing I did notice but don't
think it's too big of a deal is that the moment the target stops moving it immediately starts to very slowly try to make it's
way back to the target, and then focuses completely. This is because of the addition of the delay speed, which wasn't necessary
but still let's it work. Another thing I noticed was that this uses the same box from stage 3 but it appears to work properly,
which I'm not entirely sure why since it didn't work for stage 3. Otherwise it's everything to be expected.

### Stage 5 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

#### justification ##### 
The camera works perfectly, and has two boxes that were color code with red and green, those being the speed box and push box. When the target
is in between the two it moves at speed of the speedbox and when it touches the edge it moves at the push speed, which matches the criteria.
One thing I thought was cool was that it appears to draw another two boxes that react to the target that show when it's at the speed of 
the speed box and the push speed, since it goes back to normal when the target is pushing the outside box. It's cool that raycasting was used
again to make the box always fit the screen regardless of the zoom in or zoom out, so again a big achievement.

### Code Style Review ###

#### Style Guide Infractions ####

I could not find any major infractions through the code.

#### Style Guide Exemplars ####
I noticed that they always used snake case for naming their variables, as well as always using pascal case for class names and scene names.
A great example of this is in the [fourway_pushzone](https://github.com/ensemble-ai/exercise-2-camera-control-Iemontine/blob/a397c2b1a613bff6a799a2e8a4b498ef2c2dbb38/Obscura/scripts/camera_controllers/fourway_pushzone.gd#L1)
and honestly all of the scripts that were written. This one just specifically has the most variables. 

### Best Practices Review ###


#### Best Practices Infractions ####

There could be more uses of comments throughout the code. There are a couple but not enough to really get what's happening unless you know it. I had a lot of trouble reading the raycasting sections
since it was something I wasn't familiar with and made it difficult to see how things worked.

#### Best Practices Exemplars ####

There are a couple of comments here and there, such as in the variables at the top or what some lines of code are doing, such as [here](https://github.com/ensemble-ai/exercise-2-camera-control-Iemontine/blob/a397c2b1a613bff6a799a2e8a4b498ef2c2dbb38/Obscura/scripts/camera_controllers/fourway_pushzone.gd#L31) and [here](https://github.com/ensemble-ai/exercise-2-camera-control-Iemontine/blob/a397c2b1a613bff6a799a2e8a4b498ef2c2dbb38/Obscura/scripts/camera_controllers/target_focus.gd#L5). With some more comments it would be great.
Using the raycasting itself was really impressive since there's just so much code that was used and knowing how it all worked must have taken a long time to complete.

