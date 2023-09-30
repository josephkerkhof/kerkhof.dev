---
title: "The Dots Find Their Way"
date: 2023-09-28T16:22:21-05:00
draft: false
tags:
- 🖥️ programming
- 🧠 artificial intelligence

---

I was at the end of my summer semester getting my Data Science degree at the University of Wisconsin and I was bored and needed a hobby project.

Naturally I was interested in some of the concepts of machine learning and artificial intelligence and I'd discovered something new called a "genetic" algorithm which would "evolve" as each generation passed without having specific instruction on how to solve the problem.

{{< callout text="The idea: see if moving dots can find their way through an obstacle course while trying to reach a target." >}}

 At the beginning of each generation, the dots start at the bottom and are trying to work their way to the red dot at the top which is the goal and if dots hit an obstacle or the side of the window, they "die" (stop moving).

 Here's a demo of what I came up with.

{{< video src="one-obstacle" controls="false" muted="true" autoplay="true" loop="true" width="300px" title="A simple one-obstacle course" >}}

What's important to note here is that the dots aren't being fed instructions on how to move from their starting location to the finishing point (the red dot). Instead, each of the dots move about randomly at the start and as generations pass, each iteration gets better and better at finding the correct path. After each generation the best dots are picked and future generations apply random deviations to the movements from the best of the last generation.

You can see that the first few generations look pretty random, but by about generation 5 or 6 the dots pretty much have it figured out. By generation 8 or so it's about the same for each iteration and they've stopped improving.

To determine which dots did the best in a generation, a success function is used:

```java
public void calculateFitness(Pair<Integer, Integer> goalPosition){
    if(goalReached){
        fitness = 1.0 / 16.0 + 10000.0 / Math.pow(brainStep, 2);
    } else {
        double distanceToGoal = calcDistanceToGoal(goalPosition);
        fitness = 1.0 / Math.pow(distanceToGoal, 2);
    }
}
```

This function heavily rewards dots that reach the red dot in the fewest steps possible (the number of steps the dot takes is the `brainStep` variable). If the dot does not reach the goal, we need to figure out how close it got and reward the dots that get closer. In this fitness funcion, higher numbers are better.

OK, cool. The dots can find their way through a one-obstacle course, but how about something more complex? Let's make it more interesting... Moar obstaclez!!!

{{< video src="two-obstacles" controls="false" muted="true" autoplay="true" loop="true" width="300px" title="A two-obstacle course" >}}

{{< video src="three-obstacles" controls="false" muted="true" autoplay="true" loop="true" width="300px" title="A three-obstacle course" >}}

The later generations are interesting with the more advanced courses, especially the three-obstacle course. You can see for the three-obstacle course that generations 5-9 have this odd backtracing towards the bottom right corner. But around generation 10 or so the dots find their way around the left side of the top obstacle. Because the success function also rewards fewer steps to get to the goal, you can see final generations also optimize for getting their quicker. Pretty cool.

This was really fun and rewarding project messing around with genetic algorithms. It was also nice to use Java, which was a language I hadn't used much since my undergrad days.

If you'd like to check out the source code for this project, you can do so [here](https://github.com/josephkerkhof/path-finding-ai).
