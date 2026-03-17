## Анализ выполнения запросов без индексов и с ними
Запросы в `db/hw-scripts/explain_analyze_index.sql`.


### 1

##### Без индексов
1.1
![img-1.1.png](images/img-1.1.png)

1.2
![img-1.2.png](images/img-1.2.png)

##### B-tree индекс
1.1
![img-1.1b.png](images/img-1.1b.png)
1.2
![img-1.2b.png](images/img-1.2b.png)

После создания b-tree индекса:
 - план изменился с Parallel Seq Scan на Index Scan;
 - cost и фактическое время выполнения запроса резко уменьшились; 
 - количество shared hit снизилось.

##### Hash индекс
1.1
![img-1.1h.png](images/img-1.1h.png)
1.2
![img-1.2h.png](images/img-1.2h.png)

После создания hash индекса:
 - вместо Seq Scan был выбран Index Scan, при этом время выполнения и cost чуть ниже чем у b-tree
 - также в отличие от b-tree, shared hit стал 3 вместо 4

### 2

##### Без индексов
2.1
![img-2.1.png](images/img-2.1.png)

2.2
![img-2.2.png](images/img-2.2.png)

##### B-tree индекс
2.1
![img-2.1b.png](images/img-2.1b.png)

2.2
![img-2.2b.png](images/img-2.2b.png)

После создания b-tree индекса:
 - план не изменился - остался Seq Scan (так как диапазон значений таков, что подходят под условие подавляющее число 
   строк (видно по rows))

##### Hash индекс
2.1
![img-2.1h.png](images/img-2.1h.png)

2.2
![img-2.2h.png](images/img-2.2h.png)

После создания hash индекса:
 - использован Seq Scan, так как Hash индекс не используется при поиске по диапазону

### 3

##### Без индексов
3.1
![img-3.1.png](images/img-3.1.png)

3.2
![img-3.2.png](images/img-3.2.png)

##### B-tree индекс
3.1
![img-3.1b.png](images/img-3.1b.png)

3.2
![img-3.2b.png](images/img-3.2b.png)

После создания b-tree индекса:
 - план изменился с Seq Scan на Bitmap Index Scan + Bitmap Heap Scan
 - уменьшился cost и время выполнения

##### Hash индекс
3.1
![img-3.1h.png](images/img-3.1h.png)

3.2
![img-3.2h.png](images/img-3.2h.png)

После создания hash индекса:
- использован Seq Scan, так как Hash индекс не используется при поиске по префиксу

### 4

##### Без индексов
4.1
![img-4.1.png](images/img-4.1.png)

4.2
![img-4.2.png](images/img-4.2.png)

##### B-tree индекс
4.1
![img-4.1b.png](images/img-4.1b.png)

4.2
![img-4.2b.png](images/img-4.2b.png)

После создания b-tree индекса:
 - план не поменялся, потому что поиск по суффиксу - индекс не эффективен

##### Hash индекс
4.1
![img-4.1h.png](images/img-4.1h.png)

4.2
![img-4.2h.png](images/img-4.2h.png)

После создания hash индекса:
- использован Seq Scan, так как Hash индекс не используется для поиска по суффиксу

### 5

##### Без индексов
5.1
![img-5.1.png](images/img-5.1.png)

5.2
![img-5.2.png](images/img-5.2.png)


##### B-tree индекс
5.1
![img-5.1b.png](images/img-5.1b.png)

5.2
![img-5.2b.png](images/img-5.2b.png)

После создания b-tree индекса:
 - план не изменился из-за того, что слишком большое количество строк попадает под условие, а также присутствуют 
   триггеры


##### Hash индекс
Создать составной Hash индекс нельзя.