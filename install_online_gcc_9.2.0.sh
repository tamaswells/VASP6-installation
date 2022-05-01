#!/bin/bash
#来自学术之友公众号的Tamas，我把7.1.0改成了9.2.0
            
if  [[ -f "mpfr-4.1.0.tar.gz" ]] && [[ -f "mpc-1.2.0.tar.gz" ]] && [[ -f "gcc-9.2.0.tar.gz" ]] && [[ -f "gmp-6.2.0.tar.bz2" ]]  && [[ -f "m4-1.4.18.tar.gz" ]] ;then
    true
else
    echo  "One of mpfr-4.1.0.tar.gz,mpc-1.2.0.tar.gz,gmp-6.2.0.tar.bz2,gcc-9.2.0.tar.gz is missing."
    wget https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.gz         
    wget http://mirrors.nju.edu.cn/gnu/mpc/mpc-1.2.0.tar.gz            
    wget http://mirrors.nju.edu.cn/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.gz  
    wget https://ftp.gnu.org/pub/gnu/gmp/gmp-6.2.0.tar.bz2 
    wget https://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz
fi

gcc1=`gcc -dumpversion | awk '{split($0,a,"."); print a[1]}'`

if [ $gcc1 -gt 9 ];then
    echo "GCC version is higher than 9, no need to install gcc-9"
    exit 1
fi
    
read -p "Input installation directory for 9.2.0--->" gcc9dir
if [ ! -n "$gcc9dir" ]; then
  echo "Wrong: not a valid directory";
  exit 1
fi
mkdir -p $gcc9dir
if [ ! -d "$gcc9dir" ]; then
  echo "Wrong: no permission or not a valid directory."
  exit 1
fi

read -p "To use 9.2.0 after installation: source $gcc9dir/env.sh   hit ENTER to continue!" ok

install_needed(){
    echo "installing m4 ..."
    tar -zxvf  m4-1.4.18.tar.gz
    cd m4-1.4.18

    CC=gcc CXX=g++ ./configure --prefix=$gcc9dir/m4-1.4.18
    sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
    echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
    make 
    make install
    export M4_HOME=$gcc9dir/m4-1.4.18
    export PATH=$M4_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$M4_HOME/lib:$LD_LIBRARY_PATH
    export INCLUDE=$M4_HOME/include:$INCLUDE
    cd ../;
    rm -rf m4-1.4.18
        
    echo "installing gmp ..."
    tar -jxvf  gmp-6.2.0.tar.bz2
    cd gmp-6.2.0

    CC=gcc CXX=g++ ./configure --prefix=$gcc9dir/gmp-6.2.0
    make 
    make install
    export GMP_HOME=$gcc9dir/gmp-6.2.0
    export PATH=$GMP_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$GMP_HOME/lib:$LD_LIBRARY_PATH
    export INCLUDE=$GMP_HOME/include:$INCLUDE

    cd ../
    rm -rf gmp-6.2.0

    echo "installing mpfr ..."
    tar -zxvf mpfr-4.1.0.tar.gz
    cd mpfr-4.1.0
    CC=gcc CXX=g++ ./configure --prefix=$gcc9dir/mpfr-4.1.0 --with-gmp=$GMP_HOME
    make 
    make install

    export MPFR_HOME=$gcc9dir/mpfr-4.1.0
    export PATH=$MPFR_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$MPFR_HOME/lib:$LD_LIBRARY_PATH
    export INCLUDE=$MPFR_HOME/include:$INCLUDE

    cd ../
    rm -rf mpfr-4.1.0

    echo "installing mpc ..."
    tar -zxvf mpc-1.2.0.tar.gz
    cd mpc-1.2.0
    CC=gcc CXX=g++ ./configure --prefix=$gcc9dir/mpc-1.2.0 --with-gmp=$GMP_HOME --with-mpfr=$MPFR_HOME
    make 
    make install

    export MPC_HOME=$gcc9dir/mpc-1.2.0
    export PATH=$MPC_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$MPC_HOME/lib:$LD_LIBRARY_PATH
    export INCLUDE=$MPC_HOME/include:$INCLUDE

    cd ../
    rm -rf mpc-1.2.0
}

install_needed

#to prevent LIBRARY_PATH containing the current directory
unset LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE
echo "installing gcc-9 ..."
tar -zxvf gcc-9.2.0.tar.gz
cd gcc-9.2.0
sed -e '1161 s|^|//|' -i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc
CC=gcc CXX=g++ ./configure --prefix=$gcc9dir/gcc-9.2.0 --with-gmp=$GMP_HOME --with-mpfr=$MPFR_HOME --with-mpc=$MPC_HOME --disable-multilib --enable-languages=c,c++,fortran

make 
make install
export GCC_HOME=$gcc9dir/gcc-9.2.0
export PATH=$GCC_HOME/bin:$PATH
export LD_LIBRARY_PATH=$GCC_HOME/lib:$GCC_HOME/lib64:$LD_LIBRARY_PATH
export INCLUDE=$GCC_HOME/include:$INCLUDE
cd ../
rm -rf gcc-9.2.0 

echo "export m4_HOME=$gcc9dir/m4-1.4.18" >> $gcc9dir/env.sh
echo 'export PATH=$m4_HOME/bin:$PATH' >> $gcc9dir/env.sh
echo 'export LD_LIBRARY_PATH=$m4_HOME/lib:$LD_LIBRARY_PATH' >> $gcc9dir/env.sh
echo 'export INCLUDE=$m4_HOME/include:$INCLUDE' >> $gcc9dir/env.sh
echo "export GMP_HOME=$gcc9dir/gmp-6.2.0" >> $gcc9dir/env.sh
echo 'export PATH=$GMP_HOME/bin:$PATH' >> $gcc9dir/env.sh
echo 'export LD_LIBRARY_PATH=$GMP_HOME/lib:$LD_LIBRARY_PATH' >> $gcc9dir/env.sh
echo 'export INCLUDE=$GMP_HOME/include:$INCLUDE' >> $gcc9dir/env.sh
echo "export MPFR_HOME=$gcc9dir/mpfr-4.1.0" >> $gcc9dir/env.sh
echo 'export PATH=$MPFR_HOME/bin:$PATH' >> $gcc9dir/env.sh
echo 'export LD_LIBRARY_PATH=$MPFR_HOME/lib:$LD_LIBRARY_PATH' >> $gcc9dir/env.sh
echo 'export INCLUDE=$MPFR_HOME/include:$INCLUDE' >> $gcc9dir/env.sh
echo "export MPC_HOME=$gcc9dir/mpc-1.2.0" >> $gcc9dir/env.sh
echo 'export PATH=$MPC_HOME/bin:$PATH' >> $gcc9dir/env.sh
echo 'export LD_LIBRARY_PATH=$MPC_HOME/lib:$LD_LIBRARY_PATH' >> $gcc9dir/env.sh
echo 'export INCLUDE=$MPC_HOME/include:$INCLUDE' >> $gcc9dir/env.sh
echo "export GCC_HOME=$gcc9dir/gcc-9.2.0/" >> $gcc9dir/env.sh
echo 'export PATH=$GCC_HOME/bin:$PATH' >> $gcc9dir/env.sh
echo 'export LD_LIBRARY_PATH=$GCC_HOME/lib:$GCC_HOME/lib64:$LD_LIBRARY_PATH' >> $gcc9dir/env.sh
echo 'export INCLUDE=$GCC_HOME/include:$INCLUDE' >> $gcc9dir/env.sh
