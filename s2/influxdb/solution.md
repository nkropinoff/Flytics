## Подготовка
`docker compose up -d` - запуск docker
`http://localhost:8086` - web gui

## Задания
- Создание базы через веб\-интерфейс - bucket `industrial_sensors`
![img.png](images/img-1.png)

- Наполнение данными (промышленных) датчиков
```
current,motor_id=M-1001,type=induction,load=high value=145.5
current,motor_id=M-1001,type=induction,load=high value=148.2
current,motor_id=M-1002,type=synchronous,load=medium value=98.1
current,motor_id=M-1002,type=synchronous,load=medium value=102.4
pressure,pipe_id=MP-01,section=main,zone=A value=4.2
pressure,pipe_id=MP-01,section=main,zone=A value=4.5
pressure,pipe_id=MP-02,section=bypass,zone=B value=2.1
pressure,pipe_id=MP-02,section=bypass,zone=B value=2.3
```
![img.png](images/img-2.png)

- Просмотреть все данные за последние 30 минут
```
from(bucket: "industrial_sensors")
  |> range(start: -30m)
```
![img_1.png](images/img-3.png)
![img.png](images/img-4.png)

- Посмотреть измерения только 1 датчика
```
from(bucket: "industrial_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "current" and r["motor_id"] == "M-1001")
```
![img.png](images/img-5.png)

- Максимальное значение на 1 датчике
```
from(bucket: "industrial_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "current" and r["motor_id"] == "M-1001")
  |> max()
```
![img.png](images/img-6.png)

- Среднее значение на датчике
```
from(bucket: "industrial_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "pressure" and r["pipe_id"] == "MP-01")
  |> mean()
```
![img.png](images/img-7.png)

- 2-3 аналитических запроса с фильтром по значению

Ток > 100
```
from(bucket: "industrial_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "current")
  |> filter(fn: (r) => r["_value"] > 100.0)
```
![img.png](images/img-8.png)

Давление < 3.0 в зоне B
```
from(bucket: "industrial_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "pressure" and r["zone"] == "B")
  |> filter(fn: (r) => r["_value"] < 3.0)
```
![img.png](images/img-9.png)

- Запрос на агрегацию данных
```
from(bucket: "industrial_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "current")
  |> aggregateWindow(every: 15m, fn: mean, createEmpty: false)
  |> yield(name: "mean_current_15m")
```
![img.png](images/img-10.png)


- создайте Dashboard с 1-2 графиками
Слева график с показаниями тока, а справа с давлением 
![img.png](images/img-11.png)