from __future__ import print_function
groovy = open("view.dsl", "w")

my_dict = {}

with open('populate.txt') as f:
    for line in f:
        items = line.split()
        key, values = items[0], items[1]
        my_dict[key] = values


print (my_dict)

print ("nestedView('project-a') { ", file = groovy)
print ("  views {", file = groovy)

for key, value in my_dict.iteritems():
    print ("buildPipelineView(\'%s\') {"  %(key), file = groovy)
    print ("   selectedJob(\'%s\')" %(value), file = groovy)
    print ("  }", file = groovy)


print (" }", file = groovy)
print ("}", file = groovy)

