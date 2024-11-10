# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.


### Ответ 

1. Сервисный аккаунт задается в variavles.tf. Права storage.admin, для работы с бакетом. 
2. Провайдер и бакет описаны в [providers.tf](https://github.com/alexandreevich/devops-diplom-yandexcloud/blob/main/terraform/providers.tf) После того, как инфраструктура разворачивается, мы разкоменнтируем блок backend "S3" и инициализируем инфраструктуру коммандой 
```
terraform init
```
![Снимок экрана 2024-11-10 в 14 08 57](https://github.com/user-attachments/assets/7938d628-39d9-43b2-90a7-03f2d0faf4ec)


После этого, terraform.tfstate хранится в бакете и можно выполнит `terraform destroy` и `terraform apply` без дополнительных ручных действий.
Продемонстрирую это скриншотами, что бы не тратить бюджет. После этого переместил файл terraform.tfstate к себе и сделал terraform init -upgrade.

![Снимок экрана 2024-11-10 в 14 09 28](https://github.com/user-attachments/assets/18ea55a0-7e3a-4660-bf86-78e593513927)


3. Все переменные описаны в файле [variables.tf](https://github.com/alexandreevich/devops-diplom-yandexcloud/blob/main/terraform/variables.tf)
4. Нам потребуются 3 ВМ для разворачивания кластера k8s + gitlab. 
Гитлаб берем в соответствии с рекомендацией Яндекса, [gitlab.tf](https://github.com/alexandreevich/devops-diplom-yandexcloud/blob/main/terraform/gitlab.tf) 
5. В логику control-plane и worker-nodes закладываем сразу счетчик для возможности масштабироваться. Подсети задаем используя по умолчанию 2 значения и распределение между ними(для георезервирования) через "% length". [control_plane.tf](https://github.com/alexandreevich/devops-diplom-yandexcloud/blob/main/terraform/control_plane.tf) [worker.tf](https://github.com/alexandreevich/devops-diplom-yandexcloud/blob/main/terraform/worker.tf)
6. Для удобства задаем циклы для формирования инвентарника - [ansible.tf](https://github.com/alexandreevich/devops-diplom-yandexcloud/blob/main/terraform/ansible.tf)

Развернутые ВМ: 

![Снимок экрана 2024-11-10 в 14 21 12](https://github.com/user-attachments/assets/7c2bce89-5dad-4cee-8607-90be890eb7b7)


Отрабатывает команда terraform apply:

![Снимок экрана 2024-11-10 в 14 03 41](https://github.com/user-attachments/assets/3fc64fa1-a912-4621-9d9f-f5f43a53aa9a)



---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.




### Ответ

1. Накатывал с помощью [kubespray](https://github.com/kubernetes-sigs/kubespray)
Сразу не отработало, надо было в плейбуке "Check Ansible version" поправить версию до "maximal_ansible_version: 2.17.6"
После отработал штатно:

![Снимок экрана 2024-11-03 в 14 48 18](https://github.com/user-attachments/assets/b8259e74-03c0-439a-88e1-97eef146c407)


2. Кластер корректно развернулся, команды отрабатывают штатно:

![Снимок экрана 2024-11-03 в 14 51 27](https://github.com/user-attachments/assets/c3fb9795-2de6-401c-8db8-26e886af5380)
 

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.


### Ответ

1. Создан репозиторий [nginx-for-diplom](https://github.com/alexandreevich/nginx-for-diplom)
2. Imige пушится в [DockerHub](https://hub.docker.com/repository/docker/alexandreevich/nginx-image/general). Сам [Dockerfile](https://github.com/alexandreevich/nginx-for-diplom/blob/main/Dockerfile)
3. Первую сборку осуществлял локально:

![Снимок экрана 2024-11-03 в 15 40 41](https://github.com/user-attachments/assets/c70b511a-4cc7-4247-9dad-b4831f82ab6c)

4.  Пуш тоже корректно отработал:

![Снимок экрана 2024-11-03 в 15 42 43](https://github.com/user-attachments/assets/cd45cc5f-9296-45fb-bf8e-cfe933ae7568)



---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.


### Ответ
1. Установку осуществлял через helm. В отдельный namespace monitoring.

![Снимок экрана 2024-11-03 в 15 53 21](https://github.com/user-attachments/assets/004dc21b-6cdd-4552-bc16-efc34aaf6757)

2. Grafana корректно развернулась, дашборд импортировал стандартный, ID 315:

<img width="1431" alt="Снимок экрана 2024-11-03 в 15 58 08" src="https://github.com/user-attachments/assets/b6e4e344-2ab0-43f6-be2d-e45bee784fab">

Список достпуных дашбордов:

<img width="1440" alt="Снимок экрана 2024-11-03 в 15 59 31" src="https://github.com/user-attachments/assets/fd6c995c-9578-4241-995b-9132133e7371">

Пример: 

![Снимок экрана 2024-11-10 в 12 44 26](https://github.com/user-attachments/assets/ee337b6f-6c2a-4050-9895-697987858427)



3.  Тестовое приложение деплоится двумя манифестами, service и  deployment, соответственно, лежат [тут](https://github.com/alexandreevich/nginx-for-diplom/tree/main/k8s)
 Развернулось корректно:
 ![Снимок экрана 2024-11-06 в 13 29 20](https://github.com/user-attachments/assets/17148e45-265d-496a-8ccf-e9083872d365)





---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.


### Ответ

Тут пришлось потанцевать с бубном, так как изначально я планировал использоват привычный мне jenkins. И я уже начал его разворачивать через  DevOps Tools. 
Но оказалось, что есть определенные сложности с настройкой Docker'a и это не считается best practis. Ввиду этого, все зачистил, развернул отдельный инстанс Gitlab. 

Не все шло гладко: 

![Снимок экрана 2024-11-06 в 21 40 55](https://github.com/user-attachments/assets/90b1f3eb-fa57-4949-bc5d-e98ccc4d2c5f)

<img width="1049" alt="Снимок экрана 2024-11-07 в 00 24 37" src="https://github.com/user-attachments/assets/5ae9a8ed-0afb-412b-87aa-e5596f4a6bf2">



### Настройка Runnera

1. Выделил ему отдельный namespace
2. Создал сервисный аккаунт [serviceaccount.yaml](https://github.com/alexandreevich/nginx-for-diplom/blob/main/runner/serviceaccount.yaml)
3. В UI Gitlab создал runner, вытащил токен. Сохранил его в k8s:
```
kubectl --namespace=gitlab-runner create secret generic runner-secret --from-literal=runner-registration-token="MY_TOKEN" --from-literal=runner-token=""
```
4. Используя helm добавил чарт и применил [values](https://github.com/alexandreevich/nginx-for-diplom/blob/main/runner/value.yml):
```
helm repo add gitlab https://charts.gitlab.io
helm install gitlab-runner gitlab/gitlab-runner -n gitlab-runner -f runner/values.yml
```
<img width="942" alt="Снимок экрана 2024-11-08 в 15 28 49" src="https://github.com/user-attachments/assets/de5cb3ca-5074-4fff-8b9c-14a9f07716c8">


И применил так же [ClusterRole.yml](https://github.com/alexandreevich/nginx-for-diplom/blob/main/runner/ClusterRole.yml) и [ClusterRoleBinding](https://github.com/alexandreevich/nginx-for-diplom/blob/main/runner/ClusterRoleBinding.yaml)

5. Так же на worker-node's был установлен Docker. 
По итогу, в namespace gitlab-runner развернут gitlab-runner. Осуществлен проброс volume_mounts, для доступа к Docker. Runner'у создана кластрер роль и осуществлена привязка к ней.
Раннер может осуществлять деплой в любой namespace(да, ювелирней было бы дать ему права на определенный, признаю)

![Снимок экрана 2024-11-07 в 15 35 14](https://github.com/user-attachments/assets/1d453cb6-da13-4e4b-8f9c-64c8fe923b48)


6. С настройкой runner'a все, идем дальше.


### CI/CD 

1. В UI Gitlab'a добавил свой аккаунт в docker и полученный в нем token:

![Снимок экрана 2024-11-10 в 13 31 01](https://github.com/user-attachments/assets/68c29e6f-5816-4813-a8d1-9b3036482806)


2. Все конфиги прописаны в [.gitlab-ci.yml](https://github.com/alexandreevich/nginx-for-diplom/blob/main/.gitlab-ci.yml)
Сборка и отправка в dockerhub осуществляется по любому коммиту в main ветку.

![Снимок экрана 2024-11-10 в 13 33 49](https://github.com/user-attachments/assets/62524663-3ac0-4ee8-8dd1-0ea5e103bd91)

3. Если проставляется тег, то осуществляется деплой в кластер: 

![Снимок экрана 2024-11-10 в 13 34 14](https://github.com/user-attachments/assets/ffc02ebf-1c53-4e8e-81fb-16cb0cf76704)

4. Логика проставки тега к image задается через IF: если тег не проставлен, то проставляются первые 8 символов хеша коммита. (CI_COMMIT_SHORT_SHA)

![Снимок экрана 2024-11-10 в 13 40 19](https://github.com/user-attachments/assets/f36d0412-6eeb-4465-b054-385aa01d64ab)

Если же проставлен тег в коммите, то ставится он и осущуствляется deploy. 

![Снимок экрана 2024-11-10 в 13 41 09](https://github.com/user-attachments/assets/233177e9-0bf8-483f-be0f-d821e24a5f75)

###  Demo

1. Проставляем изменения в статику и тег в git: 

![Снимок экрана 2024-11-10 в 13 43 28](https://github.com/user-attachments/assets/54add257-fab9-496e-839a-10cad38b6eb1)

2. Получаем   ![Снимок экрана 2024-11-10 в 13 34 14](https://github.com/user-attachments/assets/fd011419-92cd-4b98-a2e9-0ebccb0e4b32)

3. И изменения по  http:

<img width="1431" alt="Снимок экрана 2024-11-09 в 15 01 15" src="https://github.com/user-attachments/assets/77cbe902-b277-4758-9681-b677e3b2be82">






---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

