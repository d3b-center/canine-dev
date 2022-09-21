import sys
import yaml

inyaml = sys.argv[-1]

with open(inyaml, "r") as f:
  data = yaml.safe_load(f)

count = 0
for batch in data["calling_intervals"]:
  outname = "scatter_interval_{}.bed".format(count)
  with open(outname, "w") as f:
    for interval in batch:
      f.write("{}\t{}\t{}\n".format(interval["contig"], interval["start"] - 1, interval["stop"]))
  count += 1
