# 2026 年错误集合

------------------
解析器返回异常值，需要先检查解析器是否正确，即使这个解析器不是你自己写的

案例：

`682,917 pt (8,033位)` => `6829178033`

```typescript
const points = numExtractor(row('累計ポイント').text().trim());
```

------------------
不能完全相信 AI，如果感觉不对，应该做专门进行验证。（显然 AI 又在胡编了）

案例：
Q： monogodb 原本是 int，改成 long 没问题么？

GPT-5.5 A:
结论：一般没问题，但建议做一次类型统一。

MongoDB 里 int32 和 int64 都是数值类型，**查询和排序通常可正常工作（吐槽：真的么？）**。你从应用层把字段改成 Long，绝大多数场景不会出问题。

需要注意的点：
1. 旧数据可能还是 int32，新写入是 int64，会出现同一字段混合类型。
2. 如果你有 collection validator 严格限制 bsonType 为 int，需要同步改规则。
3. 为了后续稳定（统计、导出、跨语言读写一致），建议把历史 int32 全量转成 int64。

建议你先检查当前类型分布：
```javascript
db.metadata.aggregate([
  { $match: { points: { $ne: null } } },
  { $group: { _id: { $type: "$points" }, count: { $sum: 1 } } }
])
```

如果看到 int，就执行一次迁移：
```javascript
db.metadata.updateMany(
  { points: { $type: "int" } },
  [{ $set: { points: { $toLong: "$points" } } }]
)
```

迁移后再跑一次上面的 aggregate 确认只剩 long/null 即可。  
所以答案是：能用，但生产上最好做一次统一迁移，避免隐性兼容问题。


实际：
```
org.bson.BsonInvalidOperationException: Reading field 'points' failed expected INT64 type but found: INT32.
```

----------------
