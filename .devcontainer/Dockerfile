FROM dart

RUN apt-get update
RUN apt-get install -y curl git unzip xz-utils zip libglu1-mesa

RUN apt-get clean

ENV TZ=Africa/Johannesburg
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Installing Flutter SDK
RUN curl -fsSL https://fvm.app/install.sh | bash
#RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /flutter
#ENV PATH="/flutter/bin:$PATH"
#RUN flutter channel stable
#RUN flutter upgrade
#RUN flutter doctor
