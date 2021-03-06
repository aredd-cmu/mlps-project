library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(text2vec)

# load data
data = read_tsv("Data/train.tsv")

# replace no item descriptions with nas
data$item_description[data$item_description == "No description yet"] = NA

# which columns have nas
apply(data, 2, function(x) any(is.na(x)))

# total number of nas
data %>% is.na() %>% colSums()

# View item descriptions by category
data %>% filter(is.na(item_description)) %>%  group_by(category_name) %>% count() 

# View category structure
data %>% 
  select(category_name) %>% 
  unique() %>% 
  mutate(num = str_count(category_name, pattern = "/")) %>% 
  filter(num != 2) %>% View()

# break out categories and join final categoies together
data = data %>%  
  mutate(category_list = category_name %>% strsplit(split = "/"),
                           category_name_1 = category_list[[1]][1],
                           category_name_2 = category_list[[1]][2],
                           category_name_3 = category_list[[1]][-(1:2)] %>% paste(collapse = "/"))

testing = data %>% head(10) %>% select(train_id, item_description)

it_train = itoken(testing$item_description,
                  preprocessor=tolower,
                  tokenizer=word_tokenizer,
                  ids = testing$train_id,
                  progressbar = FALSE)

stop_words = c("a", "about", "above", "after", "again", "against", "all", "am", "an", "and", "any", "are", "arent", "as", "at", "be", "because", "been", "before", "being", "below", "between", "both", "but", "by", "cant", "cannot", "could", "couldnt", "did", "didnt", "do", "does", "doesnt", "doing", "dont", "down", "during", "each", "few", "for", "from", "further", "had", "hadnt", "has", "hasnt", "have", "havent", "having", "he", "hed", "hell", "hes", "her", "here", "heres", "hers", "herself", "him", "himself", "his", "how", "hows", "i", "id", "ill", "im", "ive", "if", "in", "into", "is", "isnt", "it", "its", "its", "itself", "lets", "me", "more", "most", "mustnt", "my", "myself", "no", "nor", "not", "of", "off", "on", "once", "only", "or", "other", "ought", "our", "ours", "ourselves", "out", "over", "own", "same", "shant", "she", "shed", "shell", "shes", "should", "shouldnt", "so", "some", "such", "than", "that", "thats", "the", "their", "theirs", "them", "themselves", "then", "there", "theres", "these", "they", "theyd", "theyll", "theyre", "theyve", "this", "those", "through", "to", "too", "under", "until", "up", "very", "was", "wasnt", "we", "wed", "well", "were", "weve", "were", "werent", "what", "whats", "when", "whens", "where", "wheres", "which", "while", "who", "whos", "whom", "why", "whys", "with", "wont", "would", "wouldnt", "you", "youd", "youll", "youre", "youve", "your", "yours", "yourself", "yourselves")

vocab = create_vocabulary(it_train, stopwords = stop_words)

vectorizer = vocab_vectorizer(vocab)

dtm_testing = create_dtm(it_train, vectorizer)
data %>% filter(category_name %>%  is.na()) %>% select(starts_with("cat")) %>% View()
testing



