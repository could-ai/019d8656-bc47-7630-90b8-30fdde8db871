import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseKey)

    const payload = await req.json()
    
    // Basic validation
    if (!payload.title || !payload.summary || !payload.category || !payload.source) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // Check for duplicates based on title or articleUrl
    let query = supabase.from('news_articles').select('id')
    
    if (payload.articleUrl) {
      query = query.eq('article_url', payload.articleUrl)
    } else {
      query = query.eq('title', payload.title)
    }

    const { data: existing } = await query.limit(1)

    if (existing && existing.length > 0) {
      return new Response(
        JSON.stringify({ message: 'Article already exists', id: existing[0].id }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
      )
    }

    // Insert new article
    const { data, error } = await supabase
      .from('news_articles')
      .insert([
        {
          title: payload.title,
          summary: payload.summary,
          image_url: payload.imageUrl,
          category: payload.category,
          source: payload.source,
          article_url: payload.articleUrl,
          is_breaking: payload.isBreaking || false,
        }
      ])
      .select()

    if (error) throw error

    return new Response(
      JSON.stringify({ message: 'Article inserted successfully', data }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 201 }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
