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

 At the beginning of each generation, the dots start at the bottom and are trying to work their way to the red dot at the top which is the goal. Here's a demo of what I came up with.

{{< video src="path-finding-1" controls="false" muted="true" autoplay="true" loop="true" width="300px" title="A simple obstacle" >}}

What's important to note here is that the dots aren't being fed instructions on how to move from their starting location to the finishing point (the red dot). Instead, each of the dots move about randomly at the start and as generations pass, each iteration gets better and better at finding the correct path. After each generation the best dots are picked and future generations apply random deviations to the movements from the best of the last generation.

You can see that the first few generations look pretty random, but by about generation 5 or 6 the dots pretty much have it figured out. By generation 8 or so it's about the same for each iteration and they've stopped improving.

To determine which dots did the best in a generation a success function is used:

```java
public void calculateFitness(Pair<Integer, Integer> goalPosition){
    if(goalReached){
        fitness = 1.0 / 16.0 + 10000.0 / Math.pow(brainStep, 2);
    } else {
        double distanceToGoal = calcDistanceToGoal(goalPosition);
        fitness = 1.0 / Math.pow(distanceToGoal, 2);
    }
    if(fitness == Double.POSITIVE_INFINITY) {
        fitness = 1;
    }
}
```
