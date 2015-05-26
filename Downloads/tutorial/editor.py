import subprocess as sb
path_to_FEBio = "/Users/robertnims/Downloads/tutorial/FEBio-1/febio.osx"

filepath = ["/Users/robertnims/Downloads/tutorial/6percent-ctrl-"]

samples_pergroup = 4

ending1 = "/TEMPLATE_opt.feb"
ending2 = "/TEMPLATE_opt.log"
t=[]
files_to_run =[]
t.insert(0,input('Which file should be rerun? '))
file_try = 0
while t[0]:
    t.insert(0,input('Any more files to be rerun? (enter 0 to exit) '))

t=sorted(t)
t = t[1::]
print t
    
for i in t:
    file_try=0
    for j in filepath:
        for k in range(0, samples_pergroup):
            file_try+=1
            if file_try == i:
                file_i = j+str(k+1)+ending1
                print file_i
                files_to_run.append(file_i)
                f = open(file_i,'r')
                f_temp = open('temp.feb','w')
                for line in f.readlines():
                    if line.find("param name") != -1:
                        print "Current values:\n"
                        print line+"\n"
                        val=[]
                        val.append(input("what is the initial guess? "))
                        val.append(input("what is the low guess? "))
                        val.append(input("what is the high guess? "))
                        a = line.find(">",0)
                        b = line.find(",",a)
                        c = line.find(",",b)
                        d = line.find(",",c)
                        e = line.find("<",d)
                        line_i = line[0:a+1]+str(val[0])+","+str(val[1])+","+ str(val[2])+","+str(val[0])+line[e::]
                        f_temp.write(line_i)
                    else:
                        f_temp.write(line)
                f.close()
                f_temp.close()
                with open('temp.feb') as f:
                    with open(file_i,'w') as f1:
                        for line in f:
                            f1.write(line)

frun = open('file.dat','w')
filenum=0
for j in files_to_run:
    sb.call([path_to_FEBio,"-s",j])
    frun.write(str(t[filenum])+' ')
    i = 0
    for line in reversed(open(j[0:-3]+"log").readlines()):
        i+=1
        if i == 2:
            if line.replace(' N O R M A L   T E R M I N A T I O N\n','xx') == 'xx':
                frun.write('normal\n')
            else:
                frun.write('fail\n')
    filenum+=1
filenum=0
fsave=open('filesrun.dat','a')
for k in files_to_run:
    f = open(k[0:-3]+"log")
    fsave.write(str(t[filenum])+'\n')
    filenum+=1
    j = 0
    for line in reversed(f.readlines()):
        j+=1
        if j>5:
            break
        else:
            if j>2:
                fsave.write(line)


                            
