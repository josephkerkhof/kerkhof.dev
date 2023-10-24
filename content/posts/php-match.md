---
title: "A Match Made in PHP"
date: 2023-10-10T18:21:00-05:00
draft: false
tags:
- 🖥️ programming

---

PHP is [often criticized](http://www.phpsadness.com/) for being a bad language. Developers often point to the

- inconsistent [function names](http://www.phpsadness.com/sad/4)
- inconsistent [parameter order](http://www.phpsadness.com/sad/6)
- a history of [insecure mysql](https://www.youtube.com/watch?v=_jKylhJtPmI) functions
- there is a lot of bad PHP code in the world

Despite these criticisms (though the last isn't really PHP's fault), PHP remains a very popular web language choice. There are plenty of [mature](https://laravel.org/), [well-tested](https://wordpress.org) [frameworks](https://drupal.org) to [make](https://symfony.com/) getting started easy. [Composer](https://getcomposer.org/) is an excellent package manager and there are no [shortage](https://codeception.com/) of [testing](https://phpunit.de/) [libraries](https://pestphp.com/).

Yet, PHP consistently ranks near the middle of the pack of desired and admired technologies in the [StackOverflow Developer Survey](https://survey.stackoverflow.co/2023/#technology-admired-and-desired). PHP is perhaps the boring choice. But boring isn't _necessarily bad_. Boring can means stable which means capital investment can proceed more confidently.

This isn't to say there aren't still quality-of-life improvements happening in the PHP world. PHP 8 brought in the new JIT compiler, more type hinting, attributes, and other new language features.

One such quality-of-life language feature is PHP's new `match` statement. You can think of it as a fancy ternary statement with more flexibility.

Here's an example of how `match` works in action:

```php
$suit = 'hearts';

$suit_string = match ($suit) {
    'spades' => 'We are holding spades',
    'clubs' => 'We are holding clubs',
    'hearts' => 'We are holding hearts',
    'diamonds' => 'We are holding diamonds',
    default => 'unknown'
};

print($suit_string); // Prints "We are holding hearts"
```

The syntax is fairly easy to understand even to someone who hasn't seen it before. We are assigning a variable on the condition that a variable matches a set of conditions. This is very similar to the `switch` statement, but there are a couple differences.

1. The match function uses an identity check (`===`) where the switch statement uses a weak equality check (`==`) (`2 === '2'` will return `false`).
2. The `match` expression returns a value. The case statement doesn't return anything.
3. The `match` expression can perform non-identity checks.

The `match` syntax is much less verbose than `switch`, especially if a variable is being set.

Here's the logical equivalent using `switch`:

```php
$suit = 'hearts';

$suit_string = '';

switch ($suit) {
    case 'spades':
        $suit_string = 'We are holding spades';
        break;
    case 'clubs':
        $suit_string = 'We are holding clubs';
        break;
    case 'hearts':
        $suit_string = 'We are holding hearts';
        break;
    case 'diamonds':
        $suit_string = 'We are holding diamonds';
        break;
    default:
        $suit_string = 'unknown';
}

print($suit_string); // Prints "We are holding hearts"
```

Look at all those extra `break;` and `case` statements and variable assignment operations. Gross!

Something else `switch` cannot do that `match` can: perform non-identity checks (`===`) by passing `true` into the subject expression:

```php
$old_decades = ['1940s', '1950s', '1960s', '1970s', '1980s'];
$selected_decade = '1990s';

$output = match (true) {
    in_array($selected_decade, $old_decades) => 'The selected decade is old!',
    $selected_decade === '1990s' => 'The selected decade is not old!'
};

print($output); // Prints "The selected decade is not old!"
```

This is a new level of succinctness, power, and expression. Once you start using `match` it's easy to see many useful applications. Here's the classic fizzbuzz program implemented using `match`:

```php
$n = 100;

for ($i = 1; $i <= $n; $i++) {
    print match(0) {
        $i % 3 + $i % 5 => "FizzBuzz" . PHP_EOL,
        $i % 3 => "Fizz" . PHP_EOL,
        $i % 5 => "Buzz" . PHP_EOL,
        default => $i . PHP_EOL
    };
}

// 1
// 2
// Fizz
// 4
// Buzz
// Fizz
// 7
// 8
// Fizz
// Buzz
// 11
// Fizz
// 13
// 14
// FizzBuzz
// 16
// ...
```

That was simple with clear, readable syntax!
