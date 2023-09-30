---
title: "The Dots Find Their Way"
date: 2023-09-28T16:22:21-05:00
draft: false
tags:
- 🖥️ programming
- 🧠 artificial intelligence

---

I was at the end of the summer semester while getting my Masters in Data Science and I was bored and needed a hobby project.

Naturally, I was interested in concepts I was learning about in machine learning and I had discovered something called a "genetic" algorithm. A genetic algorithm would "evolve" as each generation passed without having specific instructions on how to explicitly solve the problem.

{{< callout text="The idea: see if moving dots can find their way through an obstacle course while trying to reach a target." >}}

 At the beginning of each generation, the dots start at a given location and try to work their way towards a goal. In my example, the dots start at the bottom of a window and try to move towards a red dot (the goal) at the top. If a dot hits an obstacle or the side of the window, they "die" or stop moving.

 Here's what I came up with:

{{< video src="one-obstacle" controls="false" muted="true" autoplay="true" loop="true" width="300px" title="A simple one-obstacle course" >}}

What's important to note is that the dots aren't fed instructions on how to move from their starting location towards their goal (the red dot). Instead, each dot moves about randomly at the start. As each generation passes, iterations get better and better at finding a workable path. The best dots are picked to represent future generations with minor random deviations applied to their movement history. The cycle repeats.

You can see that the first few generations look pretty random, but by about generation 5 or 6 the dots pretty much have the simple course figured out. By generation 8 or so they've stopped improving.

To determine which dots did the best in a generation, this success function is used:

```java
public void calculateFitness(Pair<Integer, Integer> goalPosition) {
    if(goalReached) {
        fitness = 1.0 / 16.0 + 10000.0 / Math.pow(numSteps, 2);
    } else {
        double distanceToGoal = calcDistanceToGoal(goalPosition);
        fitness = 1.0 / Math.pow(distanceToGoal, 2);
    }
}
```

The function rewards dots that reach the goal (the red dot) in the fewest steps the most. If the dot doesn't reach the goal, we need to figure out how close the dot came to the goal and reward the dots that get closer (a simple 2D distance function is used). Higher numbers means the dots are fitter.

OK, so dots can find their way through a one-obstacle course. How about something more complex? Let's make it interesting with moar obstaclez!!!

{{< video src="two-obstacles" controls="false" muted="true" autoplay="true" loop="true" width="300px" title="A two-obstacle course" >}}

{{< video src="three-obstacles" controls="false" muted="true" autoplay="true" loop="true" width="300px" title="A three-obstacle course" >}}

Later generations are interesting with the more advanced courses, especially the three-obstacle course. You can see for the three-obstacle course that generations 5-9 have this odd backtracking towards the bottom right corner. But around generation 10 or so the dots find their way around the left side of the top obstacle. Because the success function also rewards fewer steps to get to the goal, you can see final generations optimizing for getting there quicker. Pretty cool.

This was really fun and rewarding project messing around with genetic algorithms. It was also nice to use Java, which was a language I hadn't cracked open much since my undergrad days.

If you'd like to check out the source code for this project, you can do so [here](https://github.com/josephkerkhof/path-finding-ai).
