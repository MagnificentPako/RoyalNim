FROM nimlang/nim:onbuild
RUN apt-get install -y libzip-dev
CMD ["serve"]
ENTRYPOINT ["./RoyalNim"]
