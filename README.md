# IOPS 基準測試

Research for IOPS tools, and design benchmark with different test environment.

研究 IOPS 工具並設計用於硬碟的基準測試，以下研究應包括：

## 測試工具

[Fio](https://fio.readthedocs.io/en/latest/fio_doc.html) 工具可允許自訂測試內容來測量讀寫 ​​IOPS；若測試隨機 4K 讀取 IOPS 的常見配置如下：

```
fio --name=TEST --eta-newline=5s --filename=/path/to/testfile.dat --rw=randread --size=500m --io_size=10g --blocksize=4k --fsync=1 --iodepth=1 --direct=1 --numjobs=1 --runtime=60 --group_reporting
```

其中主要 Fio 參數描述如下：

+ ```--name=TEST```: 測試項目名稱。
+ ```--filename=/path/to/testfile.dat```: 指定一個測試檔案，若檔案不存在， FIO 會建立該檔案；另外可以使用 ```--directory``` 指定測試檔案讀寫於目錄內。
+ ```--rw=randread```: 設定 I/O 模式為隨機讀取；選項共包括讀取 ( read )、寫入 ( write )、隨機讀取 ( randread )、隨機寫入 ( randwrite )。
+ ```--size=500m```: 指定測試檔案的大小，範例為 500 MB。
+ ```--io_size=10g```: 指定 I/O 傳輸總量，範例為 10 GB。
+ ```--blocksize=4k```: 設定 I/O 區塊大小，範例為 4KB；區塊大小對於 IOPS 至關重要，因為較小的區塊通常可帶來更高的 IOPS。
+ ```--fsync=1```: 每次寫入後強制進行檔案系統同步，確保資料提交到磁碟。
+ ```--iodepth=1```: 設定 I/O 的深度，即在任意給定時間內可執行的 I/O 操作數量，當數值越高，模擬的並發請求越多。
+ ```--direct=1```: 設定繞過作業系統緩存，直接寫入儲存設備。
+ ```--numjobs=1```: 設定要執行的並發 I/O 作業數量。
+ ```--runtime=60```: 設定持續測試時間的秒數。
+ ```--group_reporting```: 提供執行內容報告。
+ ```--output=mytest_report.txt```：將 FIO 輸出（包括作業統計資料和日誌）導向到名為 mytest_report.txt 的檔案。

## 測試環境

### 容器內硬碟

此測試項目會啟動容器執行環境，並對容器環境中的檔案目錄測試。

以 ```bm base``` 啟動環境，依據執行 randread、randwrite、read、writ 腳本。
以 ```bm base --into``` 啟動環境並進入容器。

### 容器掛載目錄

此測試項目會啟動容器執行環境，並對容器環境中掛載的檔案目錄測試。

以 ```bm volume``` 啟動環境，依據執行 randread、randwrite、read、writ 腳本。
以 ```bm volume --into``` 啟動環境並進入容器。

### In-Memory Filesystem

記憶體檔案系統 ( In-Memory filesystem )，建立這是一個完全存在於 RAM 中的檔案系統 tmpfs；由於本質上檔案系統存在於記憶體，寫入的任何資料都駐留在記憶體中；但當卸載 tmpfs 或重新啟動作業系統後，資料會像記憶體中的內容一樣遺失。

此測試項目會啟動容器執行環境，並對容器中掛載記憶體檔案系統的目錄測試。

以 ```bm tmpfs``` 啟動環境，依據執行 randread、randwrite、read、writ 腳本。

使用記憶體檔案系統，其操作參考如下：

##### Create a tmpfs in Linux system

在 Linux 系統中，可使用 mount 命令建立 tmpfs 類型驅動並掛載於特定目錄；例如，建立一個 1GB 容量的 tmpfs 並掛載於 /mnt/ramdisk 目錄：

```
sudo mount -t tmpfs -o size=1G tmpfs /mnt/ramdisk
```

使用命令 ```mount -t tmpfs``` 檢查所有 tmpfs 類型目錄，或使用 ```df /mnt/ramdisk -h``` 顯示掛載目錄的資訊。

##### Create a tmpfs in Docker container

在 Docker 系統中，使用 ```--tmpfs``` 或 ```--mount``` 參數建立容器的 tmpfs 目錄；例如，在 bash 容器建立一個 1GB 容量的 tmpfs 並掛載於 /tmp 目錄：

```
docker run -ti --rm \
  --mount type=tmpfs, destination=/tmp, tmpfs-size=1G \
  bash
```

若在 Docker compose 中使用則如下：

```
services:
  server:
    image: bash
    tmpfs:
      - /tmp:size=1G
```

## 文獻

+ [fio - Flexible I/O tester](https://fio.readthedocs.io/en/latest/fio_doc.html)
    - [測試Block Storage效能 - 本地碟效能測試命令](https://www.alibabacloud.com/help/tc/ecs/user-guide/test-the-performance-of-block-storage-devices#section-f8v-673-2po)  
    - [NAS效能測試](https://www.alibabacloud.com/help/tc/nas/user-guide/test-the-performance-of-a-nas-file-system)
    - [Linux fio 測試參數的眉眉角角](https://blog.jaycetyle.com/2021/10/linux-fio-tips/)
