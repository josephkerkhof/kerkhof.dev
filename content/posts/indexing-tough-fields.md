---
title: "Indexing Tough Fields in MySQL"
date: 2024-04-07T13:56:00-06:00
draft: false
tags:
  - 🖥️ programming
  - 📊 databases

---

# Intro

When working with a database, you're often working with a lot of data, and it's likely necessary to search through that data quickly. One excellent option to help with this is to use indexes to speed up your queries. But what if you're working with a field (or multiple fields used together) that are quite long and difficult to index? It is possible to index these fields, but what are the trade-offs and how can you do it effectively?

# The Setup

I had a cron job that ran every hour parsing data from our commissions table. This commissions table had millions of rows including two fields: Google Click IDs and the conversion timestamp. Google Click IDs (gclid) are up to 100 characters long, and when combined with a timestamp, can tell Google which ad click resulted in a conversion on our platform.

My cron job needed to upload new commissions to Google's API but only if the commission hadn't been uploaded before (ex. the first instance of a gclid + conversion timestamp combination). Because multiple commissions can have the same gclid and timestamp, I needed to search for all commissions with the same gclid and timestamp, get the first one, and upload that one to Google.

# The Problem

I needed a way to perform `SELECT` queries quickly for each of the commission records I processed. My first thought was to reach for a composite index containing the gclid and the conversion timestamp. 

Since the gclid and timestamp are both long fields and the gclid can be up to 100 characters in length, I was concerned about the file size of the index on the database. Even though the speed would probably be fine, the size of the index could get pretty unruly. Was there a more efficient way to index these fields without sacrificing querying speed?

# My Solution

Rather than using a composite index, I decided to use an MD5 hash with the concatenation of the gclid and timestamp fields. Because I was searching on these fields combined, I could create a new `computed` field in MySQL. This way if one of the two fields (gclid or conversion timestamp) ever changed, the MD5 hash would be recalculated as well.

Because all MD5 hashes have fixed lengths, I could also take advantage of a smaller field and index size by storing it as a binary blob. This would also make the index faster to search. MD5 hashes can fit inside a 16-byte binary field.

Here's how I created the computed field:

```sql
-- Create the new, computed field to store the MD5 hash
ALTER TABLE commissions
ADD COLUMN gclid_conversion_timestamp_hash BINARY(16) 
AS (UNHEX(MD5(CONCAT(gclid, conversion_timestamp))) STORED;

-- Create an index on the new field
CREATE INDEX gclid_conversion_timestamp_hash_index ON commissions (gclid_conversion_timestamp_hash);
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

This solution has worked really well for me and my team. Our `SELECT` queries run in fractions of a second now that this new index is in place and the index is stored efficiently. It's amazing how many records the MySQL database can sort through giving you all results that have the same gclid and conversion timestamp.