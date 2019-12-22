FROM node:12-slim
ADD benchmark/ benchmark/

CMD ["node", "benchmark"]
