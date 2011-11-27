using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.WebTesting;
using System.Globalization;
using System.Text;
using System.ComponentModel;

namespace VSTSPrototype
{
    [DescriptionAttribute("Extracts the selected option of select")]
    [DisplayNameAttribute("Custom Extract Selected")]
    public class CustomExtractionSelected : ExtractionRule
    {
        [DescriptionAttribute("Enter the value of the element's name attribute")]
        private string NameValue;
        public string Name
        {
            get { return NameValue; }
            set { NameValue = value; }
        }

        // The Extract method.  The parameter e contains the web performance test context.
        //---------------------------------------------------------------------
        public override void Extract(object sender, ExtractionEventArgs e)
        {
            if (e.Response.HtmlDocument != null)
            {
                int skip = 1;
                foreach (HtmlTag tag in e.Response.HtmlDocument.GetFilteredHtmlTags(new string[] { "select", "option" }))
                {
                    if (String.Equals(tag.GetAttributeValueAsString("name"), Name, StringComparison.InvariantCultureIgnoreCase))
                    {
                        skip = 0;
                    }
                    else if (skip == 0)
                    {
                        if (String.Equals(tag.GetAttributeValueAsString("selected"), "selected", StringComparison.InvariantCultureIgnoreCase))
                        {
                            e.WebTest.Context.Add(this.ContextParameterName, tag.GetAttributeValueAsString("value"));
                            e.Success = true;
                            return;
                        }
                    }
                    else
                    {
                        skip = 1;
                    }
                }
            }
            // If the extraction fails, set the error text that the user sees
            e.Success = false;
            e.Message = String.Format(CultureInfo.CurrentCulture, "Not Found: {0}", Name);
        }
    }
}
