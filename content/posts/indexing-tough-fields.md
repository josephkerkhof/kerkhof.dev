---
title: "Indexing Tough Fields in MySQL"
date: 2024-04-07T13:56:00-06:00
draft: false
tags:
  - 🖥️ programming
  - 📊 databases

---

# Intro

When working with a database, you're often working with a lot of data, and it's likely necessary to search through that data quickly. One excellent option is to use indexes to speed up your queries. But what if you're working with a field (or multiple fields used together) that are long are difficult to index?

# The Setup

I had a cron job that I was working on that ran every hour. Our commission's table had millions of rows. Google Click IDs (gclid) are up to 100 characters long, and when combined with a timestamp, tell Google which ad click resulted in a conversion.

My cron job needed to upload new commissions to Google's API but only if the commission hadn't been uploaded before (ex. the first instance of a gclid + timestamp combination).

# The Problem

My first thought was to reach for a composite index containing both the gclid and the conversion timestamp. 

Since the gclid and timestamp are both long fields, I was concerned about the size of the index. I was also concerned about the performance of the index since the gclid field is a string. The sheer size of our commission's table made me concerned about this approach to my query speed problem.

# My Solution

Rather than using a composite index, I decided to use an MD5 hash of the combination of the gclid and timestamp fields. Because I was only using this field for searching for an amalgamation of the two fields, I could create this new field as a `computed` field in MySQL. This way if one of the two fields ever changed, the MD5 hash would change as well.

Because the MD5 hash has a fixed length I could also take advantage of a smaller field an index size by storing it as a binary blob. This would also make the index faster to search. MD5 hashes can fit inside a 16-byte binary field.

Here's how I created the computed field:

```sql
-- Create the new, computed field to store the MD5 hash
ALTER TABLE commissions
ADD COLUMN gclid_timestamp_hash BINARY(16) 
AS (UNHEX(MD5(CONCAT(gclid, timestamp))) STORED;

-- Create an index on the new field
CREATE INDEX gclid_timestamp_hash_index ON commissions (gclid_timestamp_hash);
```

# Some Trade-offs

I would not be a good developer unless I threw in some "it depends on your situation" caveats. Here are some things to consider:

- MD5 hashes
  - They aren't reversible. If you need to know the original values of the gclid and timestamp, you'll need to store them separately. In my case, this was already done for me; the only change I made was creating a new field to store the hash.
  - They aren't guaranteed to be unique. If you have a lot of data, you may run into hash collisions. This is a very low probability because the chance of an MD5 hash collision is 1 in 2^128 - a very low chance indeed. If you're worried about this, you could use a different hash function like SHA-256.
- It might be considered a little unorthodox to use `computed` fields in a database.
  - Inserts & Updates: Be careful your calculated field isn't too complex and slow to calculate. The calculations occur on inserts/updates and are included as part of the runtime of the database transaction.
  - Portability: Not all databases support computed fields. MySQL does, but if you ever need to move to a different database, you may need to rethink your approach.
  - Complexity: Computed fields can add complexity to your database schema. If you're working with a team, make sure they understand what you're doing and why.

# Conclusion

This solution has worked really well for me and my team. Our `SELECT` queries run in fractions of a second now that this new index is in place. It's amazing how many records the MySQL database can sort through to give you all results that have this same gclid and timestamp.