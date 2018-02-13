using SimpleWcfClient.CalculatorService;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;
using System.Text;
using System.Threading.Tasks;

namespace SimpleWcfClient
{
    class Program
    {
        static void Main(string[] args)
        {
            ChannelFactory<ICalculator> factory = new ChannelFactory<ICalculator>("BasicHttpsBinding_ICalculator");
            factory.Endpoint.EndpointBehaviors.Add(new CustomBehavior());
            //var client = factory.CreateChannel();
            var client = factory.CreateChannel(new EndpointAddress("https://allapis.azure-api.net/calc"));

            var number = client.Add(1, 2);

            Console.WriteLine(number.ToString());
        }
    }

    public class CustomBehavior : IEndpointBehavior
    {
        public void AddBindingParameters(ServiceEndpoint endpoint, BindingParameterCollection bindingParameters)
        {
        }

        public void ApplyClientBehavior(ServiceEndpoint endpoint, ClientRuntime clientRuntime)
        {
            clientRuntime.ClientMessageInspectors.Add(new CustomInspector());
        }

        public void ApplyDispatchBehavior(ServiceEndpoint endpoint, EndpointDispatcher endpointDispatcher)
        {
        }

        public void Validate(ServiceEndpoint endpoint)
        {
        }
    }

    public class CustomInspector : IClientMessageInspector
    {
        public void AfterReceiveReply(ref Message reply, object correlationState)
        {
        }

        public object BeforeSendRequest(ref Message request, IClientChannel channel)
        {
            HttpRequestMessageProperty reqProps = request.Properties[HttpRequestMessageProperty.Name] as HttpRequestMessageProperty;
            if(reqProps == null)
            {
                reqProps = new HttpRequestMessageProperty();
            }

            reqProps.Headers.Add("Ocp-Apim-Trace", "true");
            reqProps.Headers.Add("Ocp-Apim-Subscription-Key", "3557045a7c444312b1741911a09bb1d1");
            request.Properties[HttpRequestMessageProperty.Name] = reqProps;

            return null;
        }
    }
}
