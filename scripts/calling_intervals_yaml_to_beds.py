import sys
import yaml

inyaml = sys.argv[-1]
payload = inyaml.split('/')[-1].split('.')[0]

with open(inyaml, "r") as f:
  data = yaml.safe_load(f)

count = 0
for batch in data[payload]:
  outname = "scatter_interval_{:03d}.bed".format(count)
  with open(outname, "w") as f:
    for interval in batch:
      f.write("{}\t{}\t{}\n".format(interval["contig"], interval["start"] - 1, interval["stop"]))
  count += 1
