import * as Chart from 'chart.js';
import axios from './ajax'

interface IGetServerResponse {
  data: ISecret[]
}

interface ISecret {
  deployment_status: string,
  instances_count: number
}

interface IChartData {
  keys: string[],
  values: number[]
}

interface INameToValueMap {
  [key: string]: string
}

export default class HomeChart {
  private instancesCountUrl = 'project_instances_counts'
  private chartSelector: HTMLCanvasElement
  private statusesColors: INameToValueMap = {
    not_deployed: '#ffeeba',
    deploying: '#b8daff',
    destroying_instances: '#d6d8db',
    failure: '#f5c6cb',
    instances_destroyed: '#c6c8ca',
    closed: '#c6c8ca',
    running: '#c3e6cb',
    scheduled: '#bee5eb'
  }

  private statusesHumanized: INameToValueMap = {
    not_deployed: 'Not deployed',
    deploying: 'Deploying',
    destroying_instances: 'Destroying',
    failure: 'Failed',
    instances_destroyed: 'Destroyed',
    closed: 'Closed',
    running: 'Running',
    scheduled: 'Scheduled'
  }

  constructor (selector: string) {
    const element = document.getElementById(selector)
    this.chartSelector = element as HTMLCanvasElement
    if (this.chartSelector) {
      this.loadData()
    }
  }

  private loadData (): void {
    axios
      .get(this.instancesCountUrl)
      .then((response: IGetServerResponse) => {
        const instancesData: IChartData = this.structureResponseData(response.data)
        this.drawChart(instancesData)
      })
  }

  private structureResponseData (data: ISecret[]): IChartData {
    const result: IChartData = { keys: [], values: [] }

    Object.keys(this.statusesColors).forEach((statusKey) => {
      result.keys.push(this.statusesHumanized[statusKey])

      const dataItem = data.find((item) => item.deployment_status === statusKey)
      if (dataItem) {
        result.values.push(dataItem.instances_count)
      } else {
        result.values.push(0)
      }
    })

    return result
  }

  private drawChart (instancesData: IChartData): void {
    const myChart = new Chart(this.chartSelector, {
      type: 'pie',
      data: {
        datasets: [{
          backgroundColor: Object.keys(this.statusesColors).map((key) => (this.statusesColors[key])),
          data: instancesData.values
        }],
        labels: instancesData.keys
      }
    })

  }
}
