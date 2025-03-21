p @ {
  pkgs,
  inputs,
  repos,
  ...
}: let
  python3 = pkgs.python312;
in {
  # use latest python
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     python3 = pkgs.python311;
  #     python3Packages = pkgs.python311Packages;
  #   })
  # ];

  home.packages = with pkgs; [
    uv

    pipx

    pylint
    mypy

    (python3.withPackages (py-pkgs:
      with py-pkgs; [
        # tests
        flake8

        # 各种配置文件格式
        lxml
        pyyaml

        # 异步
        # asyncio

        # MS office
        xlsxwriter
        python-docx
        openpyxl

        # 函数式编程库
        toolz
        more-itertools

        # 时间相关的库
        pytz
        pendulum

        # 日志相关的库
        loguru
        coloredlogs

        # Database
        pymysql
        pymongo
        # sqlite3
        ## ORM
        sqlalchemy

        # 图像处理的库
        pillow
        opencv
        seaborn
        matplotlib

        # 音频处理
        # librosa

        # 数据处理的库
        pandas
        numpy
        scipy

        # 进度显示
        tqdm

        # AI 相关的库
        # (callPackages torch {
        #   cudaPackages.cudaVersion = "12.1";
        # })
        # torchvision

        # 数据格式
        pydantic

        #网络
        pysocks
        aiohttp
        fastapi
        hypercorn
        uvicorn
        requests
        beautifulsoup4
        scrapy
        flask

        openapi-python-client

        # GUI
        pyqt5
        pyqt6

        # Terminal 工具
        pexpect

        # 其他
        setuptools
        # ninja
        scons
      ]))
  ];
}
