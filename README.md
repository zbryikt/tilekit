TileKit
-------------------
協助下載並整理政府為主的圖磚資料。已經有一些預先建立好的設定檔可以使用，包含：

* [國土測繪中心](http://www.nlsc.gov.tw/)
* [中央地質調查所](http://www.moeacgs.gov.tw/main.jsp)
* [地理資訊圖資雲服務平台](http://tgos.nat.gov.tw/tgos/web/tgos_home.aspx)

其中有各種圖層已預先設定好下載方式，包含：
* 岩體滑動復發潛勢 (depslide)
* 集水區土石流潛勢 (debrispoten)
* 都市計劃使用分區圖 (cityusage__wmts)

更多的圖層請參閱 config/ 目錄內容。

Usage
===================

下載原始圖檔 - 下載圖檔到 img/ 下

        lsc download.ls [設定項名稱] [Z-MIN Z-MAX X Y Z]

裁圖成圖磚 ( 目前請修改檔案內容改變指定目錄)

        lsc build.ls

合成缺少的圖磚

        lsc synth.ls [圖磚目錄] [Z-MIN Z-MAX]

建立圖磚目錄向量 - 快速檢索圖磚是否存在用

        lsc vector.ls [圖磚目錄]

License
==================

MIT License.
