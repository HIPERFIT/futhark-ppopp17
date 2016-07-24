RODINIA_URL=http://www.cs.virginia.edu/~kw5na/lava/Rodinia/Packages/Current/rodinia_3.1.tar.bz2
RODINIA_MD5=047d983e62107972f217921aa0027b05  rodinia_3.1.tar.bz2
RUNS=10

RODINIA_BENCHMARKS=srad hotspot nn backprop cfd kmeans lavaMD pathfinder myocyte

all: $(RODINIA_BENCHMARKS:%=runtimes/%-rodinia.avgtime) $(RODINIA_BENCHMARKS:%=runtimes/%-futhark.avgtime)

runtimes/%.avgtime: runtimes/%.runtimes
	awk '{sum += strtonum($$0) / 1000.0} END{print sum/NR}' < $< > $@

runtimes/srad-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/srad && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/srad/runtimes $@

runtimes/srad-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/srad/srad_core.fut
	$</rodinia/srad/srad_core -r $(RUNS) -t $@ < $</rodinia/srad/data/image.in > /dev/null

runtimes/hotspot-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/hotspot && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/hotspot/runtimes $@

runtimes/hotspot-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/hotspot/hotspot.fut
	$</rodinia/hotspot/hotspot -r $(RUNS) -t $@ < $</rodinia/hotspot/data/1024.in > /dev/null

runtimes/nn-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/nn && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/nn/runtimes $@

runtimes/nn-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/nn/nn.fut
	$</rodinia/nn/nn -r $(RUNS) -t $@ < $</rodinia/nn/data/medium.in > /dev/null

runtimes/backprop-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/backprop && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/backprop/runtimes $@

runtimes/backprop-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/backprop/backprop.fut
	$</rodinia/backprop/backprop -r $(RUNS) -t $@ < $</rodinia/backprop/data/medium.in > /dev/null

runtimes/cfd-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/cfd && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/cfd/runtimes $@

runtimes/cfd-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/cfd/cfd.fut
	$</rodinia/cfd/cfd -r $(RUNS) -t $@ < $</rodinia/cfd/data/fvcorr.domn.097K.toa > /dev/null

runtimes/kmeans-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/kmeans && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/kmeans/runtimes $@

runtimes/kmeans-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/kmeans/kmeans.fut
	$</rodinia/kmeans/kmeans -r $(RUNS) -t $@ < $</rodinia/kmeans/data/kdd_cup.in > /dev/null

runtimes/lavaMD-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/lavaMD && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/lavaMD/runtimes $@

runtimes/lavaMD-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/lavaMD/lavaMD.fut
	$</rodinia/lavaMD/lavaMD -r $(RUNS) -t $@ < $</rodinia/lavaMD/data/medium.in > /dev/null

runtimes/pathfinder-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</opencl/pathfinder && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</opencl/pathfinder/runtimes $@

runtimes/pathfinder-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/pathfinder/pathfinder.fut
	$</rodinia/pathfinder/pathfinder -r $(RUNS) -t $@ < $</rodinia/pathfinder/data/medium.in > /dev/null

# Myocyte uses the CUDA version, because the OpenCL one does not
# support the workload>1 case efficiently.
runtimes/myocyte-rodinia.runtimes: rodinia_3.1-patched
	mkdir -p runtimes
	(cd $</cuda/myocyte && make clean && make && RODINIA_RUNS=$(RUNS) ./run)
	cp $</cuda/myocyte/runtimes $@

runtimes/myocyte-futhark.runtimes: futhark-benchmarks
	mkdir -p runtimes
	futhark-opencl $</rodinia/myocyte/myocyte.fut
	$</rodinia/myocyte/myocyte -r $(RUNS) -t $@ < $</rodinia/myocyte/data/medium.in > /dev/null

futhark-benchmarks:
	git clone --depth 1 https://github.com/HIPERFIT/futhark-benchmarks.git

rodinia_3.1-patched: rodinia_3.1.tar.bz2
	@if ! md5sum --quiet -c rodinia_3.1.tar.bz2.md5; then \
          echo "Your rodinia_3.1.tar.bz2 has the wrong MD5-sum - delete it and try again."; exit 1; fi
	tar jxf rodinia_3.1.tar.bz2
	mv rodinia_3.1 rodinia_3.1-patched
	patch -p0 < rodinia_3.1-some-instrumentation.patch

rodinia_3.1.tar.bz2:
	wget http://www.cs.virginia.edu/~kw5na/lava/Rodinia/Packages/Current/rodinia_3.1.tar.bz2

clean:
	rm -rf rodinia_3.1
	rm -f rodinia_3.1.tar.bz2
